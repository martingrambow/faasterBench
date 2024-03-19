terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Root module should specify the maximum provider version
      # The ~> operator is a convenient shorthand for allowing only patch releases within a specific minor release.
      version = "~> 3.92"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name = "faasterbench-resource-group-v1"
  location = var.location
}

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project}-application-insights"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "Node.JS"
}

resource "azurerm_service_plan" "faasterbench" {
  name                = "faasterbench"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_storage_account" "storage_account" {
  name = "${var.project}storagev2"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}


output "application_insights_key"{
    sensitive   = true
    value       = azurerm_application_insights.application_insights.instrumentation_key
}

output "application_insights_connection_string"{
    sensitive   = true
    value       = azurerm_application_insights.application_insights.connection_string
}
output "application_insights_app_id"{
    sensitive   = false
    value       = azurerm_application_insights.application_insights.app_id
}
output "resource_group_name" {
    value = azurerm_resource_group.resource_group.name
}
output "storage_account_name" {
    value = azurerm_storage_account.storage_account.name
}

output "primary_access_key" {
    sensitive = true
    value = azurerm_storage_account.storage_account.primary_access_key
}

output "service_plan_id" {
    value = azurerm_service_plan.faasterbench.id
}