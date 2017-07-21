variable "resourcesname" {
  default = "tlsterraform"
}

variable "count" {
  default = 2
}

# create a resource group if it doesn't exist
resource "azurerm_resource_group" "tlsterraform" {
    name = "terraformtest"
    location = "West US"
}

# create virtual network
resource "azurerm_virtual_network" "tlsterraformnetwork" {
    name = "tfvn"
    address_space = ["10.0.0.0/16"]
    location = "West US"
    resource_group_name = "${azurerm_resource_group.tlsterraform.name}"
}

# create subnet
resource "azurerm_subnet" "tlsterraformsubnet" {
    name = "tfsub"
    resource_group_name = "${azurerm_resource_group.tlsterraform.name}"
    virtual_network_name = "${azurerm_virtual_network.tlsterraformnetwork.name}"
    address_prefix = "10.0.2.0/24"
}


# create public IPs
resource "azurerm_public_ip" "tlsterraformips" {
    name = "tlsterraformips"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.tlsterraform.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "TerraformDemo"
    }
}

# create network interface
resource "azurerm_network_interface" "tlsterraformnic" {
    name = "${format("web-%02d.inf.puppet.vm", count.index+1,)}"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.tlsterraform.name}"

    ip_configuration {
        name = "${format("web-%02d.inf.puppet.vm", count.index+1,)}"
        subnet_id = "${azurerm_subnet.tlsterraformsubnet.id}"
        private_ip_address_allocation = "static"
        private_ip_address = "10.0.2.5"
        public_ip_address_id = "${azurerm_public_ip.tlsterraformips.id}"
    }
}

# create storage account
# up to 40 VHD disks per storage account
# up to 100 storage accounts per Azure account
# for testing we will use the same storage account
resource "azurerm_storage_account" "tlsterraformstorage" {
    name = "tlsterraformstorage"
    resource_group_name = "${azurerm_resource_group.tlsterraform.name}"
    location = "westus"
    account_type = "Standard_LRS"

    tags {
        environment = "staging"
    }
}

# create storage container
resource "azurerm_storage_container" "tlsterraformstoragestoragecontainer" {
    name = "vhd"
    resource_group_name = "${azurerm_resource_group.tlsterraform.name}"
    storage_account_name = "${azurerm_storage_account.tlsterraformstorage.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.tlsterraformstorage"]
}

# create virtual machine scale set
resource "azurerm_virtual_machine_scale_set" "tlsterraformvm" {
    name = "tlsterraformvm"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.tlsterraform.name}"
    #network_interface_ids = ["${azurerm_network_interface.tlsterraformnic.id}"]
    upgrade_policy_mode = "Manual"

    sku {
       name     = "Standard_A0"
       tier     = "Standard"
       capacity = 2
    }  
    
    network_profile {
       name    = "TestNetworkProfile"
       primary = true

    ip_configuration {
       name      = "TestIPConfiguration"
       subnet_id = "${azurerm_subnet.tlsterraformsubnet.id}"
      }
   }

    storage_profile_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "14.04.2-LTS"
        version = "latest"
    }

    os_profile {
        admin_username = "testadmin"
        admin_password = "Password1234!"
        custom_data    = "${file("bootstrap.sh")}"
        computer_name_prefix = "${format("web-%02d.inf.puppet.vm", count.index+1,)}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

   storage_profile_os_disk {
    name           = "osDiskProfile"
    caching        = "ReadWrite"
    create_option  = "FromImage"
    vhd_containers = ["${azurerm_storage_account.tlsterraformstorage.primary_blob_endpoint}${azurerm_storage_container.tlsterraformstoragestoragecontainer.name}"]
  } 

    tags {
        environment = "staging"
    }
}
