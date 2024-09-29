resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

module "network" {
  source = "./tf-network-module"

  resource_group_name = var.resource_group_name
  vnet_location       = var.resource_group_location

  depends_on = [azurerm_resource_group.rg]
}
