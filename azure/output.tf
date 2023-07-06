output "ManagementPublicIP" {
  value = azurerm_public_ip.mgmt-pip.ip_address
}

output "cluster_id" {
  value = local.cluster_id
}
