data "openstack_images_image_v2" "rocky_8" {
  name = "Rocky-8.8"
  most_recent = true
}

locals {
  mgmt_hostname = "mgmt"
}

resource "openstack_compute_keypair_v2" "citc_admin" {
  name       = "citc-admin-${local.cluster_id}"
  public_key = var.ssh_public_key
}

resource "openstack_networking_secgroup_v2" "external" {
  name = "external-${local.cluster_id}"
  description = "Access to the mgmt node of ${local.cluster_id}"
}

resource "openstack_networking_secgroup_rule_v2" "external_ssh_all" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.external.id
}

resource "openstack_networking_secgroup_v2" "cluster" {
  name = "cluster-${local.cluster_id}"
  description = "Access to the mgmt node of ${local.cluster_id}"
}

resource "openstack_networking_secgroup_rule_v2" "cluster_all_ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = openstack_networking_subnet_v2.cluster.cidr
  security_group_id = openstack_networking_secgroup_v2.cluster.id
}

resource "openstack_compute_instance_v2" "mgmt" {
  name = local.mgmt_hostname
  flavor_name = var.mgmt_flavor
  security_groups = [
    openstack_networking_secgroup_v2.external.name,
    openstack_networking_secgroup_v2.cluster.name,
  ]
  key_pair = openstack_compute_keypair_v2.citc_admin.name

  user_data = base64encode(data.template_file.user_data.rendered)
  metadata = {
    "cluster" = local.cluster_id
  }
  tags = ["mgmt"]

  block_device {
    uuid = data.openstack_images_image_v2.rocky_8.id
    source_type = "image"
    volume_size = 40
    boot_index = 0
    destination_type = "volume"
    delete_on_termination = true
  }

  network {
    uuid = openstack_networking_network_v2.cluster.id
  }
}

resource "openstack_compute_floatingip_v2" "mgmt" {
  pool = var.external_network_name
}

resource "openstack_compute_floatingip_associate_v2" "mgmt" {
  floating_ip = openstack_compute_floatingip_v2.mgmt.address
  instance_id = openstack_compute_instance_v2.mgmt.id
}
