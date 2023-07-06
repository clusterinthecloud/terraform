resource "azurerm_private_dns_zone" "citc" {
  name                = "citc.zone"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_a_record" "fileserver" {
  name                = "fileserver"
  zone_name           = azurerm_private_dns_zone.citc.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = azurerm_netapp_volume.shared.mount_ip_addresses
}

resource "azurerm_private_dns_zone_virtual_network_link" "citc" {
  name                  = "citc"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.citc.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = true
}
