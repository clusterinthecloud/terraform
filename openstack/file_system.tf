resource "openstack_sharedfilesystem_share_v2" "cluster_fs" {
  name             = local.cluster_id
  share_proto      = "CEPHFS"
  size             = 10
  share_type = "cephfs-type"
}

resource "openstack_sharedfilesystem_share_access_v2" "cluster_fs_access" {
  share_id     = openstack_sharedfilesystem_share_v2.cluster_fs.id
  access_type  = "cephx"
  access_to    = local.cluster_id
  access_level = "rw"
}
