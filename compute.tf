resource "oci_core_instance" "ClusterCompute" {
  count = "${var.NumComputeInstances}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "compute${count.index + 1}"
  shape = "${var.ComputeShape}"

  create_vnic_details {
    subnet_id = "${oci_core_subnet.ClusterSubnet.id}"
    display_name = "primaryvnic"
    assign_public_ip = true
    hostname_label = "compute${count.index + 1}"
  },

  source_details {
    source_type = "image"
    source_id = "${var.ComputeImageOCID[var.region]}"

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = "${base64encode(file(var.BootStrapFile))}"
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_instance" "ClusterManagement" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "mgmt"
  shape = "${var.ManagementShape}"

  create_vnic_details {
    subnet_id = "${oci_core_subnet.ClusterSubnet.id}"
    display_name = "primaryvnic"
    assign_public_ip = true
    hostname_label = "mgmt"
  },

  source_details {
    source_type = "image"
    source_id = "${var.ManagementImageOCID[var.region]}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = "${base64encode(file(var.BootStrapFile))}"
  }

  timeouts {
    create = "60m"
  }
}
