provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "this" {
  name                = "webhook-demo-vnet"
  resource_group_name = "webhook-demo-rg"
  location            = "Eastus"
  address_space       = ["10.0.0.0/16"]
}