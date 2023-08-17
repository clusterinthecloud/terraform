data "openstack_networking_network_v2" "external" {
  name = "external"
}

resource "openstack_networking_network_v2" "ClusterVCN" {
  name = "ClusterVCN-${local.cluster_id}"
  admin_state_up = "true"
  dns_domain = "${local.cluster_id}."
}

resource "openstack_networking_subnet_v2" "subnet" {
  name = "subnet-${local.cluster_id}"
  network_id = openstack_networking_network_v2.ClusterVCN.id
  cidr = "10.1.0.0/16"
  ip_version = 4
}

resource "openstack_networking_router_v2" "router_1" {
  name                = "my_router-${local.cluster_id}"
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}
