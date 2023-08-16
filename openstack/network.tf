resource "openstack_networking_network_v2" "ClusterVCN" {
  name = "ClusterVCN-${local.cluster_id}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name = "subnet_1"
  network_id = openstack_networking_network_v2.ClusterVCN.id
  cidr = "10.1.0.0/16"
  ip_version = 4
}

resource "openstack_compute_secgroup_v2" "secgroup_1" {
  name = "secgroup_1"
  description = "a security group"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_networking_port_v2" "port_1" {
  name           = "port_1"
  network_id = openstack_networking_network_v2.ClusterVCN.id
  admin_state_up = "true"
  security_group_ids = [openstack_compute_secgroup_v2.secgroup_1.id]
}
