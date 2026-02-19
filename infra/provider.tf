terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.52.0"
    }
  }

  # For lab simplicity we use local state. In real projects,
  # replace this with an azurerm backend.
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Azure Provider - for creating Azure Databricks workspace
provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id != "" ? var.azure_subscription_id : null
  # Azure credentials can be set via:
  # - Environment variables: ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID
  # - Azure CLI: az login
  # - Service Principal: configure in variables
}

provider "databricks" {
 
  host = local.databricks_workspace_url
  
  # Authentication: Use PAT token or Azure service principal
  # For Azure service principal, use: azure_client_id, azure_client_secret, azure_tenant_id
  token = var.databricks_token
  
  # Alternative: Use Azure authentication (uncomment if using service principal)
  # azure_client_id     = var.azure_client_id
  # azure_client_secret = var.azure_client_secret
  # azure_tenant_id     = var.azure_tenant_id
}

