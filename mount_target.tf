resource "oci_file_storage_mount_target" "ClusterFSMountTarget" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.FilesystemAD - 1]["name"]
  compartment_id      = var.compartment_ocid
  subnet_id           = oci_core_subnet.ClusterSubnet.id
  display_name        = "fileserver"
  hostname_label      = "fileserver"
}

