variable "resource_group_name" {
  type = string
}

variable "vnet_location" {
  type = string
}

variable "vnet_name" {
  type    = string
  default = "elasticsearchopenai-vnet"
}

variable "vnet_cidr" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet" {
  type = object(
    {
      mysqldb = object({
        name             = string
        address_prefixes = list(string)
      })

      bastion = object({
        name             = string
        address_prefixes = list(string)
      })
    }
  )

  default = {
    mysqldb = {
      name             = "mysqldb-subnet"
      address_prefixes = ["10.0.0.0/24"]
    },
    bastion = {
      name             = "bastion-subnet"
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

variable "subnet_sg" {
  type = object({
    mysqldb_subnet_sg_name = string
    bastion_subnet_sg_name = string
  })

  default = {
    mysqldb_subnet_sg_name = "mysqldb-subnet-sg"
    bastion_subnet_sg_name = "bastion-subnet-sg"
  }
}
