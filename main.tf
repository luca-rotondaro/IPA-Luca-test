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
#Date: 17.04.2022
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
  name     = "rg-${local.local_data.result.customer.shortName}-${var.azregion}-${var.management}"
  location = var.location

  tags = {
    environment = var.management
    owner       = local.local_data.result.customer.fullName
    creator     = var.creator
  }
}

# Create a resource group rg-"cusname_short"-chn-services
resource "azurerm_resource_group" "services" {
  name     = "rg-${local.local_data.result.customer.shortName}-${var.azregion}-${var.services}"
  location = var.location

  tags = {
    environment = var.services
    owner       = local.local_data.result.customer.fullName
    creator     = var.creator
  }
}

# Create a resource group rg-"cusname_short"-chn-connectivity
resource "azurerm_resource_group" "connectivity" {
  name     = "rg-${local.local_data.result.customer.shortName}-${var.azregion}-${var.connectivity}"
  location = var.location

  tags = {
    environment = var.connectivity
    owner       = local.local_data.result.customer.fullName
    creator     = var.creator
  }
}

# Create virtual network (vnet)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.local_data.result.customer.shortName}-${var.azregion}-${var.connectivity}"
  address_space       = var.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.connectivity.name

  tags = {
    environment = var.connectivity
    owner       = local.local_data.result.customer.fullName
    creator     = var.creator
  }
}

# Create subnet Gateway
resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.connectivity.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet1_address_prefix

}

# Create Subnet management for clients / workloads

resource "azurerm_subnet" "snet-management" {
  name                 = "snet-${azurerm_virtual_network.vnet.name}-management"
  resource_group_name  = azurerm_resource_group.connectivity.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet2_address_prefix

}


#AD Management

#Azure AD Group for Subscription
// nörtig? wenn ja in sep File
data "azuread_client_config" "adclientconfig" {}

resource "azuread_group" "adgroup" {
  display_name     = "current"
  owners           = [data.azuread_client_config.adclientconfig.object_id]
  security_enabled = true
}

resource "azuread_user" "aduser" {
  user_principal_name   = local.local_data.result.customer.email
  display_name          = local.local_data.result.customer.fullName
  mail_nickname         = "${local.local_data.result.customer.shortName}-${var.azregion}"
  password              = "SecretP@sswd99!"
  force_password_change = true
}

resource "azurerm_role_assignment" "adrole" {
  scope              = "/subscriptions/${local.local_data.result.azure.subscription_id}"
  role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
  principal_id       = azuread_group.adgroup.object_id
}

