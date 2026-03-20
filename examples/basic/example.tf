provider "azurerm" {
  features {}
}

module "nsg" {
  source = "../../"
}
