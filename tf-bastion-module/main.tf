resource "azurerm_public_ip" "bastion_public_ip_address" {
  name                = var.bastion_public_ip_address
  resource_group_name = var.resource_group_name
  location            = var.bastion_location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "bastion_nic" {
  name                = var.bastion_nic_name
  location            = var.bastion_location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = var.bastion_nic_ipconfig_name
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.bastion_subnet_id
    public_ip_address_id          = azurerm_public_ip.bastion_public_ip_address.id
  }

  depends_on = [azurerm_public_ip.bastion_public_ip_address]
}

resource "random_password" "bastion_vm_password" {
  length  = 16
  special = true
}

resource "azurerm_linux_virtual_machine" "bastion_vm" {
  name                  = var.bastion_vm.name
  resource_group_name   = var.resource_group_name
  location              = var.bastion_location
  network_interface_ids = [azurerm_network_interface.bastion_nic.id]
  size                  = var.bastion_vm.size
  admin_username        = var.bastion_vm.admin_username
  os_disk {
    caching              = var.bastion_vm.os_disk.caching
    storage_account_type = var.bastion_vm.os_disk.storage_account_type
    disk_size_gb         = 30
  }

  disable_password_authentication = false
  admin_password                  = random_password.bastion_vm_password.result
  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  depends_on = [azurerm_network_interface.bastion_nic, random_password.bastion_vm_password]
}
