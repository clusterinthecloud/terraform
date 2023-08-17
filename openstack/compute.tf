data "openstack_images_image_v2" "rocky_8" {
  name = "Rocky-8.8"
  most_recent = true
}

data "openstack_compute_flavor_v2" "m1_medium" {
  name = "m1.medium"
}

locals {
  mgmt_hostname = "mgmt"
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "citc-keypair-${local.cluster_id}"
  public_key = var.ssh_public_key
}

resource "openstack_compute_secgroup_v2" "secgroup_1" {
  name = "secgroup-${local.cluster_id}"
  description = "a security group"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "mgmt" {
  name = local.mgmt_hostname
  flavor_id = data.openstack_compute_flavor_v2.m1_medium.id
  security_groups = [openstack_compute_secgroup_v2.secgroup_1.name]
  key_pair = openstack_compute_keypair_v2.keypair.name

  user_data = base64encode(data.template_file.user_data.rendered)
  metadata = {
    "cluster" = local.cluster_id
  }

  block_device {
    uuid = data.openstack_images_image_v2.rocky_8.id
    source_type = "image"
    volume_size = 40
    boot_index = 0
    destination_type = "volume"
    delete_on_termination = true
  }

  network {
    uuid = openstack_networking_network_v2.ClusterVCN.id
  }
}

resource "openstack_compute_floatingip_v2" "floatip_1" {
  pool = "external"
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = openstack_compute_floatingip_v2.floatip_1.address
  instance_id = openstack_compute_instance_v2.mgmt.id
}
