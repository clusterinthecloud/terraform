data "openstack_networking_network_v2" "demovxlan" {
  name = "demo-vxlan"
}

resource "openstack_sharedfilesystem_sharenetwork_v2" "sharenetwork_1" {
  name              = "test_sharenetwork"
  description       = "test share network with security services"
  neutron_net_id    = data.openstack_networking_network_v2.demovxlan.id
  neutron_subnet_id = data.openstack_networking_network_v2.demovxlan.subnets[0]
}

resource "openstack_sharedfilesystem_share_v2" "ClusterFS" {
  name        = "ClusterFS-${local.cluster_id}"
  share_proto = "CEPHFS"
  share_type = "example-type"  # we made this in the admin area.
  size        = 10
  #share_network_id = openstack_sharedfilesystem_sharenetwork_v2.sharenetwork_1.id
}
