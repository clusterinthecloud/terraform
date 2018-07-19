resource "oci_file_storage_mount_target" "ClusterFSMountTarget" {
  #Required
  count               = "${length(var.ADS)}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.ADS[count.index] -1 ], "name")}"
  compartment_id      = "${var.compartment_ocid}"
  subnet_id           = "${oci_core_subnet.ClusterSubnet.*.id[index(var.ADS, var.ADS[count.index]) ]}"
  display_name        = "fileserver${format("%02d", count.index+1)}"
  hostname_label      = "fileserver${format("%02d", count.index+1)}"
}
