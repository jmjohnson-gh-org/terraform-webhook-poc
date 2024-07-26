provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "webhook-demo-rg"
  location = "Eastus"
}