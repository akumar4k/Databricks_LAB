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
  # Azure credentials can be set via:
  # - Environment variables: ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID
  # - Azure CLI: az login
  # - Service Principal: configure in variables
}

provider "databricks" {
  # Workspace URL:
  # - If create_workspace=false: Use var.databricks_host (existing workspace)
  # - If create_workspace=true: Use var.databricks_host initially (can be placeholder),
  #   then after first apply, use the outputted workspace_url from azurerm_databricks_workspace
  host = var.databricks_host != "" ? var.databricks_host : (var.create_workspace ? "https://placeholder.azuredatabricks.net" : "")
  
  # Authentication: Use PAT token or Azure service principal
  # For Azure service principal, use: azure_client_id, azure_client_secret, azure_tenant_id
  token = var.databricks_token
  
  # Alternative: Use Azure authentication (uncomment if using service principal)
  # azure_client_id     = var.azure_client_id
  # azure_client_secret = var.azure_client_secret
  # azure_tenant_id     = var.azure_tenant_id
}

