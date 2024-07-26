provider "azurerm" {
  features {}
}

data "azurerm_virtual_network" "this" {
  name                = "webhook-demo-vnet"
  resource_group_name = "webhook-demo-rg"
}

resource "azurerm_subnet" "this" {
  name                 = "webhook-demo-subnet"
  resource_group_name  = "webhook-demo-rg"
  address_prefixes     = ["10.0.0.0/24"]
}