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




# Create a resource group rg-"cusname_short"-chn-management
resource "azurerm_resource_group" "management" {
  name     = "rg-${var.cusname_short}-${var.azregion}-${var.management}"
  location = var.resource_groupe_location
}

# Create a resource group rg-"cusname_short"-chn-services
resource "azurerm_resource_group" "services" {
  name     = "rg-${var.cusname_short}-${var.azregion}-${var.services}"
  location = var.resource_groupe_location
}

# Create a resource group rg-"cusname_short"-chn-connectivity
resource "azurerm_resource_group" "connectivity" {
  name     = "rg-${var.cusname_short}-${var.azregion}-${var.connectivity}"
  location = var.resource_groupe_location
}


/* Virtual Machine Ubuntu */

resource "azurerm_virtual_machine" "ubuntuvm" {   /*Creat Virtual Machine "az-vm001"*/
  name                  = "${var.providerazure}-vm001"
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name.services
  /*network_interface_ids = [azurerm_network_interface.main.id]*/
  vm_size               = "Standard_DS3"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"

  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.cusname_short}-vm-windowsserver"
    admin_username = "${var.cusname_short}-admin"
    admin_password = "P@$$w0rd1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = var.services
    owner = var.cusname_short
    creator = var.cusname_short
  }
}


/* Virtual Machine Windows Server */

resource "azurerm_windows_virtual_machine" "WindowServer" {
  name                = "${var.providerazure}-vm002"
  resource_group_name = var.azurerm_resource_group.name.services
  location            = var.azurerm_resource_location
  size                = "Standard_DS3"
  admin_username      = "${var.cusname_short}-admin"
  admin_password      = "P@$$w0rd1234!"
  timezone = var.timezone
  network_interface_ids = [
    azurerm_network_interface.x.id,
  ]
}

  os_disk {
    name                 = "myosdisk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

tags = {
    environment = var.services
    owner = var.cusname_short
    creator = var.cusname_short
  }

#Create Data Hard Disk
resource "azurerm_managed_disk" "WindowsServer_Harddisk" {
  name                 = "umblabwinserv-disk1"
  location             = azurerm_resource_group.appsvm.location
  resource_group_name  = var.azurerm_resource_group.name.services
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 1024

}  





# Create virtual network 
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.cusname_short}-${var.azregion}-${var.connectivity}"
  address_space       = var.adress_prefix
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name

tags = {
    environment = var.services
    owner = var.cusname_short
    creator = var.cusname_short
  }
}

# Create subnet Gateway
resource "azurerm_subnet" "snet-GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.management.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.adress_space

}

resource "azurerm_subnet" "internal" { /*Subent for VM*/
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" { /*Network Interface for VM*/
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}
