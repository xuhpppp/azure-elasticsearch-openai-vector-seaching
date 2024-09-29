output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_details" {
  value = module.network.vnet_details
}