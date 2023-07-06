resource "azurerm_netapp_account" "anf" {
  name                = "anf-${local.cluster_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_netapp_pool" "anfpool" {
  name                = "anfpool"
  account_name        = azurerm_netapp_account.anf.name
  location            = azurerm_netapp_account.anf.location
  resource_group_name = azurerm_netapp_account.anf.resource_group_name
  service_level       = "Standard" # local.homefs_service_level
  size_in_tb          = 4 # local.homefs_size_tb
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
resource "azurerm_netapp_volume" "shared" {
  name                = "shared"
  location            = azurerm_netapp_account.anf.location
  resource_group_name = azurerm_netapp_account.anf.resource_group_name
  account_name        = azurerm_netapp_account.anf.name
  pool_name           = azurerm_netapp_pool.anfpool.name
  volume_path         = "shared"
  service_level       = "Standard"
  subnet_id           = azurerm_subnet.netapp.id
  protocols           = ["NFSv3"]
  security_style      = "Unix"
  storage_quota_in_gb = 4 * 1024

  export_policy_rule {
    rule_index        = 1
    allowed_clients   = [ "0.0.0.0/0" ]
    unix_read_write   = true
    protocols_enabled = [ "NFSv3" ]
    root_access_enabled = true
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
