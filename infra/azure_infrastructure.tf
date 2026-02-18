############################
# Azure Resource Group for Databricks
############################

resource "azurerm_resource_group" "databricks" {
  count    = var.create_workspace ? 1 : 0
  name     = var.azure_resource_group_name
  location = var.azure_location

  tags = {
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

############################
# Azure Databricks Workspace
############################

resource "azurerm_databricks_workspace" "this" {
  count               = var.create_workspace ? 1 : 0
  name                = var.databricks_workspace_name
  resource_group_name = azurerm_resource_group.databricks[0].name
  location            = azurerm_resource_group.databricks[0].location
  sku                 = var.databricks_sku

  # Enable Unity Catalog (requires Premium SKU)
  public_network_access_enabled = true
  network_security_group_rules_required = "NoAzureDatabricksRules"

  # Managed Resource Group (Azure creates this automatically)
  # managed_resource_group_name = "${var.databricks_workspace_name}-managed-rg"

  tags = {
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

############################
# Outputs for Azure Databricks Workspace
############################

output "databricks_workspace_id" {
  description = "Azure Databricks workspace resource ID"
  value       = var.create_workspace ? azurerm_databricks_workspace.this[0].id : null
}

output "databricks_workspace_url" {
  description = "Azure Databricks workspace URL"
  value       = var.create_workspace ? azurerm_databricks_workspace.this[0].workspace_url : null
}

output "databricks_workspace_name" {
  description = "Azure Databricks workspace name"
  value       = var.create_workspace ? azurerm_databricks_workspace.this[0].name : null
}
