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
    hostname_label   = "mgmt"
  }

  source_details {
    source_type = "image"
    source_id   = var.ManagementImageOCID[var.region]
  }

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}${data.tls_public_key.oci_public_key.public_key_openssh}"
    user_data           = base64encode(data.template_file.user_data.rendered)
  }

  timeouts {
    create = "60m"
  }

  freeform_tags = {
    "cluster"  = var.ClusterNameTag
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
ad_root: ${substr(
    oci_core_instance.ClusterManagement.availability_domain,
    0,
    length(oci_core_instance.ClusterManagement.availability_domain) - 1,
)}
ansible_branch: ${var.ansible_branch}
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
