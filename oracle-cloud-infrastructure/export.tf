resource "oci_file_storage_export" "ClusterFSExport" {
  export_set_id  = oci_file_storage_mount_target.ClusterFSMountTarget.export_set_id
  file_system_id = oci_file_storage_file_system.ClusterFS.id
  path           = var.ExportPathFS

  export_options {
    source          = "0.0.0.0/0"
    access          = "READ_WRITE"
    identity_squash = "NONE"
  }
}
