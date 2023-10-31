data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

data "openstack_networking_network_v2" "external_ceph" {
  name = var.ceph_network_name
}

resource "openstack_networking_network_v2" "cluster" {
  name = "network-${local.cluster_id}"
  admin_state_up = "true"
  # dns_domain = "${local.cluster_id}."
}

resource "openstack_networking_subnet_v2" "cluster" {
  name = "subnet-${local.cluster_id}"
  network_id = openstack_networking_network_v2.cluster.id
  cidr = "10.1.0.0/16"
  ip_version = 4
}

resource "openstack_networking_router_v2" "router" {
  name = "router-${local.cluster_id}"
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.cluster.id
}
