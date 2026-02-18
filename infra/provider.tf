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
  # Workspace URL resolution:
  # - If create_workspace=true: Uses var.databricks_host (can be placeholder initially)
  # - If create_workspace=false: Uses data source or var.databricks_host
  # Note: When create_workspace=true, you'll need two-stage apply:
  #   Stage 1: Create workspace with placeholder URL
  #   Stage 2: Update databricks_host with actual workspace URL and apply again
  host = local.databricks_workspace_url
  
  # Authentication: Use PAT token or Azure service principal
  # For Azure service principal, use: azure_client_id, azure_client_secret, azure_tenant_id
  token = var.databricks_token
  
  # Alternative: Use Azure authentication (uncomment if using service principal)
  # azure_client_id     = var.azure_client_id
  # azure_client_secret = var.azure_client_secret
  # azure_tenant_id     = var.azure_tenant_id
}

