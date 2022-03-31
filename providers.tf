# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "e989b201-2a97-403e-8828-086c09894a4f"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.96.0"
    }
  }
}
