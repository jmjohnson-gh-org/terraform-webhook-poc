provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "this" {
  name          = "service-now-demo-vnet"
  name          = "service-now-demo-rg"
  location      = "Eastus"
  address_space = ["10.0.0.0/16"]
}