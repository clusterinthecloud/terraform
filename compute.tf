resource "oci_core_instance" "ClusterCompute" {
  count               = "${length(var.InstanceADIndex)}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.InstanceADIndex[count.index] - 1], "name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "compute${format("%03d", count.index+1)}"
  shape               = "${var.ComputeShapes[count.index]}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.ClusterSubnet.*.id[index(var.ADS, var.InstanceADIndex[count.index])]}"
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "compute${format("%03d", count.index+1)}"
  }

  source_details {
    source_type = "image"
    source_id   = "${lookup(var.ComputeImageOCID[var.ComputeShapes[count.index]], var.region)}"

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}${data.tls_public_key.oci_public_key.public_key_openssh}"
    user_data           = "${base64encode(file(var.BootStrapFile))}"
  }

  timeouts {
    create = "60m"
  }

  freeform_tags = {
    "cluster"  = "${var.ClusterNameTag}"
    "nodetype" = "compute"
  }
}

resource "oci_core_instance" "ClusterManagement" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.ManagementAD - 1], "name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "mgmt"
  shape               = "${var.ManagementShape}"

  create_vnic_details {
    # ManagementAD
    #subnet_id        = "${oci_core_subnet.ClusterSubnet.id}"
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
    user_data           = "${base64encode(file(var.BootStrapFile))}"
  }

  timeouts {
    create = "60m"
  }

  freeform_tags = {
    "cluster"  = "${var.ClusterNameTag}"
    "nodetype" = "mgmt"
  }
}

resource "null_resource" "copy_in_setup_data_mgmt" {
  depends_on = ["oci_core_instance.ClusterManagement"]

  triggers {
     cluster_instance = "${oci_core_instance.ClusterManagement.id}"
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
      host = "${oci_core_instance.ClusterManagement.*.public_ip}"
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
      host = "${oci_core_instance.ClusterManagement.*.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/nodes.yaml"
    content = <<EOF
---
names: ["${join("\", \"", oci_core_instance.ClusterCompute.*.display_name)}"]
shapes: ["${join("\", \"", var.ComputeShapes)}"]
EOF

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.*.public_ip}"
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
      host = "${oci_core_instance.ClusterManagement.*.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/hosts"
    content = <<EOF
[management]
${oci_core_instance.ClusterManagement.display_name}
[compute]
${join("\n", oci_core_instance.ClusterCompute.*.display_name)}
EOF

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterManagement.*.public_ip}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y ansible git",
      "nohup sudo python -u /usr/bin/ansible-pull --url=https://github.com/ACRC/slurm-ansible-playbook.git --checkout=master --inventory=/home/opc/hosts --extra-vars=\"compartment_ocid=${var.compartment_ocid}\" site.yml &>> ansible-pull.log &",
      "sleep 10"
    ]

    connection {
        timeout = "15m"
        host = "${oci_core_instance.ClusterManagement.*.public_ip}"
        user = "opc"
        private_key = "${file(var.private_key_path)}"
        agent = false
    }
  }
}

resource "null_resource" "copy_in_setup_data_compute" {
  count = "${length(var.InstanceADIndex)}"
  depends_on = ["oci_core_instance.ClusterCompute"]

  triggers {
     cluster_instance = "${oci_core_instance.ClusterCompute.*.id[count.index]}"
  }

  provisioner "file" {
    destination = "/home/opc/hosts"
    content = <<EOF
[management]
${oci_core_instance.ClusterManagement.display_name}
[compute]
${join("\n", oci_core_instance.ClusterCompute.*.display_name)}
EOF

    connection {
      timeout = "15m"
      host = "${oci_core_instance.ClusterCompute.*.public_ip[count.index]}"
      user = "opc"
      private_key = "${file(var.private_key_path)}"
      agent = false
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y ansible git",
      "nohup sudo python -u /usr/bin/ansible-pull --url=https://github.com/ACRC/slurm-ansible-playbook.git --checkout=master --inventory=/home/opc/hosts site.yml &>> ansible-pull.log &",
      "sleep 10"
    ]

    connection {
        timeout = "15m"
        host = "${oci_core_instance.ClusterCompute.*.public_ip[count.index]}"
        user = "opc"
        private_key = "${file(var.private_key_path)}"
        agent = false
    }
  }
}
