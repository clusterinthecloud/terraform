output "ip" {
 value = openstack_compute_floatingip_v2.floatip_1.address
}

output "cluster_id" {
  value = local.cluster_id
}
