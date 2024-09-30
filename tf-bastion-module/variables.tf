variable "bastion_location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "bastion_subnet_id" {
  type = string
}

variable "bastion_public_ip_address" {
  type    = string
  default = "bastion-public-ip-addr"
}

variable "bastion_nic_name" {
  type    = string
  default = "bastion-nic"
}

variable "bastion_nic_ipconfig_name" {
  type    = string
  default = "bastion-nic-ipconfig"
}

variable "bastion_vm" {
  type = object({
    name           = string
    size           = string
    admin_username = string
    os_disk = object({
      caching              = string
      storage_account_type = string
    })
  })

  default = {
    name           = "bastion-vm"
    size           = "Standard_B1s"
    admin_username = "phucdt"
    os_disk = {
      caching              = "None"
      storage_account_type = "Standard_LRS"
    }
  }
}
