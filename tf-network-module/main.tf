resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.vnet_location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_cidr
}


# MySQL subnet and security group
resource "azurerm_network_security_group" "mysqldb_subnet_sg" {
  name                = var.subnet_sg.mysqldb_subnet_sg_name
  resource_group_name = var.resource_group_name
  location            = var.vnet_location
}

resource "azurerm_subnet" "mysqldb_subnet" {
  name                 = var.subnet.mysqldb.name
  address_prefixes     = var.subnet.mysqldb.address_prefixes
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name

  default_outbound_access_enabled = false
  delegation {
    name = "mysqldb-subnet-delegation"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet_network_security_group_association" "mysqldb_subnet_sg_association" {
  subnet_id                 = azurerm_subnet.mysqldb_subnet.id
  network_security_group_id = azurerm_network_security_group.mysqldb_subnet_sg.id

  depends_on = [azurerm_network_security_group.mysqldb_subnet_sg, azurerm_subnet.mysqldb_subnet]
}


# Bastion subnet and security group
resource "azurerm_network_security_group" "bastion_subnet_sg" {
  name                = var.subnet_sg.bastion_subnet_sg_name
  resource_group_name = var.resource_group_name
  location            = var.vnet_location

  security_rule = [{
    name                                       = "AllowSSHInbound"
    protocol                                   = "Tcp"
    description                                = "Inbound rule for SSH connection"
    source_port_range                          = "*"
    source_port_ranges                         = null
    destination_port_range                     = 22
    destination_port_ranges                    = null
    source_address_prefix                      = "*"
    source_address_prefixes                    = null
    destination_address_prefix                 = "*"
    destination_address_prefixes               = null
    source_application_security_group_ids      = null
    destination_application_security_group_ids = null
    access                                     = "Allow"
    priority                                   = 100
    direction                                  = "Inbound"
  }]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = var.subnet.bastion.name
  address_prefixes     = var.subnet.bastion.address_prefixes
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet_network_security_group_association" "bastion_subnet_sg_association" {
  subnet_id                 = azurerm_subnet.bastion_subnet.id
  network_security_group_id = azurerm_network_security_group.bastion_subnet_sg.id

  depends_on = [azurerm_network_security_group.bastion_subnet_sg, azurerm_subnet.bastion_subnet]
}
