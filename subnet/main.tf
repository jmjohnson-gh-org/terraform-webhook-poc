provider "azurerm" {
  features {}
}

resource "azurerm_subnet" "this" {
  name                 = "service-now-demo-subnet"
  virtual_network_name = "service-now-demo-vnet"
  resource_group_name  = "service-now-demo-rg"
  address_prefixes     = ["10.0.0.0/24"]
}