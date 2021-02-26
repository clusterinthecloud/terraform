data "oci_core_images" "ol8" {
    compartment_id = var.compartment_ocid

    operating_system = "Oracle Linux"
    operating_system_version = "8"

    # exclude GPU specific images
    filter {
        name   = "display_name"
        values = ["^([a-zA-z]+)-([a-zA-z]+)-([\\.0-9]+)-([\\.0-9-]+)$"]
        regex  = true
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

  # Make sure that the management node depands on the filesystem so that when
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
    source_id   = data.oci_core_images.ol8.images.0.id
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
ansible_repo: ${var.ansible_repo}
ansible_branch: ${var.ansible_branch}
cluster_id: ${local.cluster_id}
mgmt_image_id: ${data.oci_core_images.ol8.images.0.id}
EOF


connection {
  timeout     = "15m"
  host        = oci_core_instance.ClusterManagement.public_ip
  user        = "opc"
  private_key = file(var.private_key_path)
  agent       = false
}
}

  provisioner "local-exec" {
    when = destroy
    command = "files/cleanup.sh"
    environment = {
      CLUSTERID = self.freeform_tags.cluster
      COMPARTMENT = self.compartment_id
    }
    working_dir = path.module
  }
}
