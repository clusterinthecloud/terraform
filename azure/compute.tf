resource "tls_private_key" "internal" {
  algorithm = "RSA"
  rsa_bits  = 2048 # This is the default
}

resource "local_file" "private_key" {
    content     = tls_private_key.internal.private_key_pem
    filename = "${path.cwd}/${local.admin_username}_id_rsa"
    file_permission = "0600"
}

resource "local_file" "public_key" {
    content     = tls_private_key.internal.public_key_openssh
    filename = "${path.cwd}/${local.admin_username}_id_rsa.pub"
    file_permission = "0644"
}

resource "azurerm_public_ip" "mgmt-pip" {
  name                = "mgmt-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "mgmt-nic" {
  name                = "mgmt-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mgmt-pip.id
  }
}

locals {
  custom_data = data.template_file.bootstrap-script.rendered
  }


resource "azurerm_linux_virtual_machine" "mgmt" {
  name                = "mgmt"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_D4s_v3"
  admin_username      = "${local.admin_username}" 
  network_interface_ids = [
    azurerm_network_interface.mgmt-nic.id,
  ]

  admin_ssh_key {
    username   = "${local.admin_username}" 
    public_key = tls_private_key.internal.public_key_openssh #file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8_4-gen2"
    version   = "latest"
  }

  provisioner "file" {
    destination = "/tmp/startnode.yaml"
    content     = data.template_file.startnode-yaml.rendered

    connection {
      type        = "ssh"
      user        = "centos"
      private_key = tls_private_key.internal.private_key_pem 
      host        = azurerm_public_ip.mgmt-pip.ip_address
    }
  }

  provisioner "file" {
    destination = "/tmp/shapes.yaml"
    source      = "${path.module}/files/shapes.yaml"

    connection {
      type        = "ssh"
      user        = "centos"
      private_key = tls_private_key.internal.private_key_pem 
      host        = azurerm_public_ip.mgmt-pip.ip_address
    }
  }

  custom_data = base64encode(local.custom_data)
}
 

resource "azurerm_role_assignment" "role_assignment" {
  scope              = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id       = "${lookup(azurerm_linux_virtual_machine.mgmt.identity[0], "principal_id")}"

  lifecycle {
    ignore_changes = [name]
  }
}
