output "bastion_vm_password" {
  value     = azurerm_linux_virtual_machine.bastion_vm.admin_password
  sensitive = true
}

output "bastion_vm" {
  value = {
    name               = azurerm_linux_virtual_machine.bastion_vm.name
    admin_username     = azurerm_linux_virtual_machine.bastion_vm.admin_username
    private_ip_address = azurerm_network_interface.bastion_nic.private_ip_address
    public_ip_address  = azurerm_linux_virtual_machine.bastion_vm.public_ip_address
  }
}
