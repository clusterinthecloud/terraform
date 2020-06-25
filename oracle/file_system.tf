resource "oci_file_storage_file_system" "ClusterFS" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.FilesystemAD - 1]["name"]
  compartment_id      = var.compartment_ocid

  freeform_tags = {
    "cluster" = local.cluster_id
  }
}
