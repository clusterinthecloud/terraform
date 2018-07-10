resource "oci_file_storage_mount_target" "ClusterFSMountTarget" {
  #Required
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1], "name")}"
  compartment_id = "${var.compartment_ocid}"
  subnet_id = "${oci_core_subnet.ClusterSubnet.id}"
}
