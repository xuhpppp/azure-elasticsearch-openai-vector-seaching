resource "random_password" "mysqldb_password" {
  length  = 16
  special = false
}

resource "azurerm_mysql_flexible_server" "mysqldb_server" {
  resource_group_name = var.resource_group_name
  location            = var.db_location
  name                = var.mysqldb_server_name

  administrator_login    = var.mysqldb_admin_username
  administrator_password = random_password.mysqldb_password.result
  delegated_subnet_id    = var.mysqldb_subnet_id
  sku_name               = var.mysqldb_sku
  version                = "8.0.21"
  storage {
    size_gb           = 20
    auto_grow_enabled = false
  }

  depends_on = [random_password.mysqldb_password]
}
