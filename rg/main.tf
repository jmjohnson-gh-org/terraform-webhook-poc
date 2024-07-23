provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "service-now-demo-rg"
  location = "Eastus"
}