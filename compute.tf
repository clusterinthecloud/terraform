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
