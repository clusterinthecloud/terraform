resource "oci_core_instance" "ClusterManagement" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.ManagementAD - 1], "name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "mgmt"
  shape               = "${var.ManagementShape}"

  create_vnic_details {
    # ManagementAD
    subnet_id = "${oci_core_subnet.ClusterSubnet.*.id[index(var.ADS, var.ManagementAD)]}"

    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "mgmt"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.ManagementImageOCID[var.region]}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}${data.tls_public_key.oci_public_key.public_key_openssh}"
    user_data           = "${base64encode(data.template_file.user_data.rendered)}"
  }

  timeouts {
    create = "60m"
  }

  freeform_tags = {
    "cluster"  = "${var.ClusterNameTag}"
    "nodetype" = "mgmt"
  }

  provisioner "file" {
    destination = "/home/opc/config"
    content = <<EOF
[DEFAULT]
user=${var.user_ocid}
fingerprint=${var.fingerprint}
key_file=/home/slurm/.oci/oci_api_key.pem
tenancy=${var.tenancy_ocid}
region=${var.region}
EOF

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }

  }

  provisioner "file" {
    destination = "/home/opc/oci_api_key.pem"
    source = "${var.private_key_path}"

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/shapes.yaml"
    source = "files/shapes.yaml"

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/mgmt_shape.yaml"
    content = <<EOF
mgmt_ad: ${var.ManagementAD}
mgmt_shape: ${var.ManagementShape}
EOF

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }
}
