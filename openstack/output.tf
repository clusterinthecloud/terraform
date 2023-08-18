output "ip" {
 value = openstack_compute_floatingip_v2.mgmt.address
}

output "cluster_id" {
  value = local.cluster_id
}
