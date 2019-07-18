# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscriptionid}"
  client_id       = "${var.clientid}"
  client_secret   = "${var.clientsecret}"
  tenant_id       = "${var.tenantid}"
}
