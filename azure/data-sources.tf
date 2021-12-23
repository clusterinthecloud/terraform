data "template_file" "bootstrap-script" {
  template = file("${path.module}/../common-files/bootstrap.sh.tpl")
  vars = {
    ansible_repo = var.ansible_repo
    ansible_branch = var.ansible_branch
    cloud-platform = "azure"
    fileserver-ip  = element(azurerm_netapp_volume.shared.mount_ip_addresses, 0)
    custom_block = templatefile("${path.module}/files/bootstrap_custom.sh.tpl", {
      dns_zone = azurerm_private_dns_zone.citc.name
      citc_keys = var.admin_public_keys
    })
    mgmt_hostname: local.mgmt_hostname
    citc_keys = var.admin_public_keys
  }
}

data "template_file" "startnode-yaml" {
  template = file("${path.module}/files/startnode.yaml.tpl")
  vars = {
    cloud-platform = "azure"
    ansible_repo = var.ansible_repo
    ansible_branch = var.ansible_branch
    region = var.region
    resource_group = azurerm_resource_group.rg.name
    subnet =  azurerm_subnet.subnet.id
    virtual_network =  azurerm_virtual_network.vnet.name
    virtual_network_subnet =  azurerm_subnet.subnet.name
    subscription = data.azurerm_subscription.primary.subscription_id
    dns_zone = azurerm_private_dns_zone.citc.name
    cluster_id: local.cluster_id
  }
}
