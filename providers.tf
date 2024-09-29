terraform {
  required_providers {
    # manage resources on Azure
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    # for generate randoms
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
