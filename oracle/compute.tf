data "oci_core_app_catalog_listings" "ol8" {
  publisher_name = "Oracle Linux"
  filter {
    name   = "display_name"
    values = ["^Oracle Linux 8.([\\.0-9-]+)$"]
    regex  = true
  }
}

data "oci_core_app_catalog_listing_resource_versions" "ol8" {
  listing_id = data.oci_core_app_catalog_listings.ol8.app_catalog_listings[0].listing_id
}

resource "oci_core_app_catalog_listing_resource_version_agreement" "ol8" {
  listing_id               = data.oci_core_app_catalog_listing_resource_versions.ol8.app_catalog_listing_resource_versions[0].listing_id
  listing_resource_version = data.oci_core_app_catalog_listing_resource_versions.ol8.app_catalog_listing_resource_versions[0].listing_resource_version
}

resource "oci_core_app_catalog_subscription" "ol8" {
  compartment_id           = var.tenancy_ocid
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.ol8.eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.ol8.listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.ol8.listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.ol8.oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.ol8.signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.ol8.time_retrieved

  timeouts {
    create = "20m"
  }
}

locals {
  mgmt_hostname = "mgmt"
}

resource "oci_core_instance" "ClusterManagement" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.ManagementAD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = local.mgmt_hostname
  shape               = var.ManagementShape

  # Make sure that the manangement node depands on the filesystem so that when
  # destroying, the filesystem is still running in order to perform cleanup of
  # any compute nodes.
  depends_on = [oci_file_storage_export.ClusterFSExport]

  create_vnic_details {
    # ManagementAD
    subnet_id = oci_core_subnet.ClusterSubnet.id

    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = local.mgmt_hostname
  }

  source_details {
    source_type = "image"
    source_id   = oci_core_app_catalog_subscription.ol8.listing_resource_id
  }

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}${data.tls_public_key.oci_public_key.public_key_openssh}"
    user_data           = base64encode(data.template_file.user_data.rendered)
  }

  timeouts {
    create = "60m"
  }

  freeform_tags = {
    "cluster" = local.cluster_id
    "nodetype" = "mgmt"
  }

  provisioner "file" {
    destination = "/home/opc/config"
    content     = <<EOF
[DEFAULT]
user=${var.user_ocid}
fingerprint=${var.fingerprint}
key_file=/home/slurm/.oci/oci_api_key.pem
tenancy=${var.tenancy_ocid}
region=${var.region}
EOF

    connection {
      timeout     = "15m"
      host        = oci_core_instance.ClusterManagement.public_ip
      user        = "opc"
      private_key = file(var.private_key_path)
      agent       = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/oci_api_key.pem"
    source      = var.private_key_path

    connection {
      timeout     = "15m"
      host        = oci_core_instance.ClusterManagement.public_ip
      user        = "opc"
      private_key = file(var.private_key_path)
      agent       = false
    }
  }

  provisioner "file" {
    destination = "/tmp/shapes.yaml"
    source      = "${path.module}/files/shapes.yaml"

    connection {
      timeout     = "15m"
      host        = oci_core_instance.ClusterManagement.public_ip
      user        = "opc"
      private_key = file(var.private_key_path)
      agent       = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/mgmt_shape.yaml"
    content     = <<EOF
mgmt_ad: ${var.ManagementAD}
mgmt_shape: ${var.ManagementShape}
EOF


    connection {
      timeout     = "15m"
      host        = oci_core_instance.ClusterManagement.public_ip
      user        = "opc"
      private_key = file(var.private_key_path)
      agent       = false
    }
  }

  provisioner "file" {
    destination = "/tmp/startnode.yaml"
    content = <<EOF
csp: oracle
region: ${var.region}
compartment_id: ${var.compartment_ocid}
vcn_id: ${oci_core_virtual_network.ClusterVCN.id}
subnet_id: ${oci_core_subnet.ClusterSubnet.id}
ad_root: ${substr(
    oci_core_instance.ClusterManagement.availability_domain,
    0,
    length(oci_core_instance.ClusterManagement.availability_domain) - 1,
)}
ansible_branch: ${var.ansible_branch}
cluster_id: ${local.cluster_id}
mgmt_image_id: ${oci_core_app_catalog_subscription.ol8.listing_resource_id}
EOF


connection {
  timeout     = "15m"
  host        = oci_core_instance.ClusterManagement.public_ip
  user        = "opc"
  private_key = file(var.private_key_path)
  agent       = false
}
}

provisioner "remote-exec" {
  when = destroy
  inline = [
    "echo Terminating any remaining compute nodes",
    "if systemctl status slurmctld >> /dev/null; then",
    "sudo -u slurm /usr/local/bin/stopnode \"$(sinfo --noheader --Format=nodelist:10000 | tr -d '[:space:]')\" || true",
    "fi",
    "sleep 5",
    "echo Node termination request completed",
  ]

  connection {
    timeout     = "15m"
    host        = self.public_ip
    user        = "opc"
    private_key = file(var.private_key_path)
    agent       = false
  }
}
}
