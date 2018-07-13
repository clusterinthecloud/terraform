resource "oci_file_storage_export" "ClusterFSExport" {
  #Required
  export_set_id  = "${oci_file_storage_mount_target.ClusterFSMountTarget.0.export_set_id}"
  file_system_id = "${oci_file_storage_file_system.ClusterFS.id}"
  path           = "${var.ExportPathFS}"
}
