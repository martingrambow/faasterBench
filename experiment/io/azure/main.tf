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

data "terraform_remote_state" "main_state" {
  backend = "local"

  config = {
    path = "../../azure-base/terraform.tfstate"
  }
}

resource "random_string" "experiment_id" {
  length  = 5
  special = false
  upper   = false
  keepers = {
    prefix = var.project_prefix
  }
}

resource "azurerm_linux_function_app" "faasterbench" {
  count               = var.WRAPPERCOUNT
  name                = "faasterbench${count.index}"
  resource_group_name = data.terraform_remote_state.main_state.outputs.resource_group_name
  location            = var.location

  storage_account_name       = data.terraform_remote_state.main_state.outputs.storage_account_name
  storage_account_access_key = data.terraform_remote_state.main_state.outputs.primary_access_key
  service_plan_id            = data.terraform_remote_state.main_state.outputs.service_plan_id
  app_settings = {
      INSTRUMENTATIONKEY = data.terraform_remote_state.main_state.outputs.application_insights_key
    }
  site_config {
    application_insights_connection_string = data.terraform_remote_state.main_state.outputs.application_insights_connection_string
    application_insights_key               = data.terraform_remote_state.main_state.outputs.application_insights_key
    application_stack {
      node_version           = "18"
    }
    

  }
}

output "FUNCTION_ENDPOINTS" {
  description = "The URLs of the Azure Function"
  value       = try(azurerm_linux_function_app.faasterbench[*].default_hostname, "")
}

output "EXPERIMENTID" {
    value = "${random_string.experiment_id.result}"
}
output "WRAPPERCOUNT"{
    value = var.WRAPPERCOUNT
}

output "APPID"{
    value = data.terraform_remote_state.main_state.outputs.application_insights_app_id
}