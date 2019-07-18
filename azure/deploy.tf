resource "azurerm_resource_group" "tsetfdemo" {
  name     = "tsetfdemorg"
  location = "West US"
}

resource "azurerm_virtual_network" "tsetfdemo" {
  name                = "tse-tf-vn"
  address_space       = ["10.0.0.0/16"]
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.tsetfdemo.name}"
}

resource "azurerm_subnet" "tsetfdemo" {
  name                 = "tsetfdemo-subnet"
  resource_group_name  = "${azurerm_resource_group.tsetfdemo.name}"
  virtual_network_name = "${azurerm_virtual_network.tsetfdemo.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "tsetfdemo" {
  name                = "itsetfdemo-acctni"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.tsetfdemo.name}"

  ip_configuration {
    name                          = "tsetfdemoconfiguration1"
    subnet_id                     = "${azurerm_subnet.tsetfdemo.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_storage_account" "tsetfdemo" {
  name                = "tsetfdemo"
  resource_group_name = "${azurerm_resource_group.tsetfdemo.name}"
  location            = "westus"
  account_type        = "Standard_LRS"

  tags {
    environment = "tse-demo"
    purpose     = "prospect eval"
    department  = "tse"
    owner       = "tommy"
  }
}


resource "azurerm_storage_container" "tsetfdemo" {
  name                  = "tsetfdemo"
  resource_group_name   = "${azurerm_resource_group.tsetfdemo.name}"
  storage_account_name  = "${azurerm_storage_account.tsetfdemo.name}"
  container_access_type = "private"
}

resource "azurerm_virtual_machine" "tsetfdemo" {
  name                  = "tsetfdemo"
  location              = "West US"
  resource_group_name   = "${azurerm_resource_group.tsetfdemo.name}"
  network_interface_ids = ["${azurerm_network_interface.tsetfdemo.id}"]
  vm_size               = "Standard_A0"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
#Offer          Publisher               Sku                 Urn                                                             UrnAlias             Version
#-------------  ----------------------  ------------------  --------------------------------------------------------------  -------------------  ---------
#WindowsServer  MicrosoftWindowsServer  2016-Datacenter     MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest     Win2016Datacenter    latest

  storage_os_disk {
    name          = "myosdisk1"
    vhd_uri       = "${azurerm_storage_account.tsetfdemo.primary_blob_endpoint}${azurerm_storage_container.tsetfdemo.name}/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "tsetfdemo"
    admin_username = "tsedemo"
    admin_password = "Puppet4Life!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}
