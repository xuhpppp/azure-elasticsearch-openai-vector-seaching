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

module "bastion" {
  source = "./tf-bastion-module"

  resource_group_name = var.resource_group_name
  bastion_location    = var.resource_group_location
  bastion_subnet_id   = module.network.vnet_details.bastion_subnet.subnet_id

  depends_on = [azurerm_resource_group.rg, module.network]
}
