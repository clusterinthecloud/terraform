output "ManagementPublicIP" {
  value = aws_instance.mgmt.public_ip
}

output "cluster_id" {
  value = local.cluster_id
}
