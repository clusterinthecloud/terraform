output "ManagementPublicIP" {
  value = oci_core_instance.ClusterManagement.public_ip
}

output "cluster_id" {
  value = local.cluster_id
}
