output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_details" {
  value = module.network.vnet_details
}

output "bastion_details" {
  value = module.bastion.bastion_vm
}

output "bastion_vm_password" {
  value     = module.bastion.bastion_vm_password
  sensitive = true
}
