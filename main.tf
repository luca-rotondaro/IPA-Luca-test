# _            _  _           _  _  _  _  _                    _           _  _  _      
#(_)          (_)(_) _     _ (_)(_)(_)(_)(_) _               _(_)_      _ (_)(_)(_) _   
#(_)          (_)(_)(_)   (_)(_) (_)        (_)            _(_) (_)_   (_)         (_)  
#(_)          (_)(_) (_)_(_) (_) (_) _  _  _(_)          _(_)     (_)_ (_)    _  _  _   
#(_)          (_)(_)   (_)   (_) (_)(_)(_)(_)_          (_) _  _  _ (_)(_)   (_)(_)(_)  
#(_)          (_)(_)         (_) (_)        (_)         (_)(_)(_)(_)(_)(_)         (_)  
#(_)_  _  _  _(_)(_)         (_) (_)_  _  _ (_)         (_)         (_)(_) _  _  _ (_)  
#  (_)(_)(_)(_)  (_)         (_)(_)(_)(_)(_)            (_)         (_)   (_)(_)(_)(_)  

#Creator: luca.rotondaro@umb.ch
#FileName: main.tf
#Date: 20.01.2022
#Description: main file für Azure Test Lab umgebung
#-->



# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used

# More information on the authentication methods supported by
# the AzureRM Provider can be found here:
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
# subscription_id = "..."
# client_id       = "..."
# client_secret   = "..."
# tenant_id       = "..."



locals {
  local_data = jsondecode(file("${path.module}/local-values.json"))
}

# Create a resource group rg-"cusname_short"-chn-management
resource "azurerm_resource_group" "management" {
  name     = "rg-${local.local_data.result.customer.custCustomerNameShort}-${var.azregion}-${var.management}"
  location = var.location
}

# Create a resource group rg-"cusname_short"-chn-services
resource "azurerm_resource_group" "services" {
  name     = "rg-${local.local_data.result.customer.custCustomerNameShort}-${var.azregion}-${var.services}"
  location = var.location
}

# Create a resource group rg-"cusname_short"-chn-connectivity
resource "azurerm_resource_group" "connectivity" {
  name     = "rg-${local.local_data.result.customer.custCustomerNameShort}-${var.azregion}-${var.connectivity}"
  location = var.location
}

# Create virtual network (vnet)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.local_data.result.customer.custCustomerNameShort}-${var.azregion}-${var.connectivity}"
  address_space       = var.adress_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.connectivity.name

  tags = {
    environment = var.services
    owner       = local.local_data.result.customer.custCustomerNameShort
    creator     = local.local_data.result.customer.custCustomerNameShort
  }
}

# Create subnet Gateway
resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.connectivity.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.adress_space_gateway

}

# Create Subnet management for clients / workloads

resource "azurerm_subnet" "snet-management" {
  name                 = "snet-${azurerm_virtual_network.vnet.name}-management"
  resource_group_name  = azurerm_resource_group.connectivity.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.adress_space_management

}


#AD Management

#Azure AD Group for Subscription

data "azuread_client_config" "current" {}

resource "azuread_group" "example" {
  display_name     = "example"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "azuread_user" "example" {
  user_principal_name = local.local_data.result.snow.snowChangeRequester
  display_name        = local.local_data.result.customer.custCustomerNameFull
  mail_nickname       = "${local.local_data.result.customer.custCustomerNameShort}-${var.azregion}"
  password            = "SecretP@sswd99!"
}
