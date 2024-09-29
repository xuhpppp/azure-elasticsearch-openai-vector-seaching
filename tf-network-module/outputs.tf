output "vnet_details" {
  value = {
    name = azurerm_virtual_network.vnet.name
    cidr = azurerm_virtual_network.vnet.address_space

    mysqldb_subnet = {
      name             = azurerm_subnet.mysqldb_subnet.name
      address_prefixes = azurerm_subnet.mysqldb_subnet.address_prefixes
    }

    bastion_subnet = {
      name             = azurerm_subnet.bastion_subnet.name
      address_prefixes = azurerm_subnet.bastion_subnet.address_prefixes
    }
  }
}
