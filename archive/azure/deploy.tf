# create a resource group - a good starting point

resource "azurerm_resource_group" "TSEDeploy" {
  name     = "tseTFdemo"
  location = "West US"  
}
