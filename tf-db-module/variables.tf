variable "resource_group_name" {
  type = string
}

variable "db_location" {
  type = string
}

variable "mysqldb_server_name" {
  type    = string
  default = "elasticsearchopenai-mysqldb-server"
}

variable "mysqldb_subnet_id" {
  type = string
}

variable "mysqldb_admin_username" {
  type    = string
  default = "phucdt"
}

variable "mysqldb_sku" {
  type    = string
  default = "B_Standard_B1ms"
}
