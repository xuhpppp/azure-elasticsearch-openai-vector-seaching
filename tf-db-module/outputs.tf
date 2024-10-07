output "mysqldb_password" {
  value     = azurerm_mysql_flexible_server.mysqldb_server.administrator_password
  sensitive = true
}

output "mysqldb_server_details" {
  value = {
    name                = azurerm_mysql_flexible_server.mysqldb_server.name
    administrator_login = azurerm_mysql_flexible_server.mysqldb_server.administrator_login
    version             = azurerm_mysql_flexible_server.mysqldb_server.version
    storage_size        = azurerm_mysql_flexible_server.mysqldb_server.storage[0].size_gb
  }
}
