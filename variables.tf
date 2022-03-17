# _            _  _           _  _  _  _  _                    _           _  _  _      
#(_)          (_)(_) _     _ (_)(_)(_)(_)(_) _               _(_)_      _ (_)(_)(_) _   
#(_)          (_)(_)(_)   (_)(_) (_)        (_)            _(_) (_)_   (_)         (_)  
#(_)          (_)(_) (_)_(_) (_) (_) _  _  _(_)          _(_)     (_)_ (_)    _  _  _   
#(_)          (_)(_)   (_)   (_) (_)(_)(_)(_)_          (_) _  _  _ (_)(_)   (_)(_)(_)  
#(_)          (_)(_)         (_) (_)        (_)         (_)(_)(_)(_)(_)(_)         (_)  
#(_)_  _  _  _(_)(_)         (_) (_)_  _  _ (_)         (_)         (_)(_) _  _  _ (_)  
#  (_)(_)(_)(_)  (_)         (_)(_)(_)(_)(_)            (_)         (_)   (_)(_)(_)(_)  

#Creator: luca.rotondaro@umb.ch
#FileName: variable.ff
#Date: 07.02.2022
#Description: Variabel File für Terraform Template
#-->


################################################################

# Azure common settings
# variable az_tags {
#    default =   { 
#                    "environment"="umblab"
#                    "owner"= var.cusname_full
#                    "creator"="luca.rotondaro@umb.ch"
#                }
#    description = "Default tags for networking components"
#}


#variable "subId" {default = "cbfc2c91-e64b-43d0-9133-32a49ee7daae"}
#in terraform.tfvars
variable "azregion" {
  type = string
}

#in terraform.tfvars
variable "providerazure" {
  type        = string
  description = "provider azure"
}

variable "environment" {
  type        = string
  description = "environment name"
}

#in terraform.tfvars
variable "location" {
  type        = string
  description = "Standard location switzerland north"
}

#in terraform.tfvars
variable "management" {
  type        = string
  description = "management resource group"
}

#in terraform.tfvars
variable "connectivity" {
  type        = string
  description = "connectivity resource group"
}

#in terraform.tfvars
variable "services" {
  type        = string
  description = "services resource group"
}

#in terraform.tfvars
variable "address_space" {
  type        = string
  description = "IP space for vnet"
}

#in terraform.tfvars
variable "subnet1_address_prefix" {
  type        = string
  description = "IP space for subnet clients"
}

#in terraform.tfvars
variable "subnet2_address_prefix" {
  type        = string
  description = "IP space for subnet gateway"
}