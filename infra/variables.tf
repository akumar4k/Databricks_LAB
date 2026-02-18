variable "create_workspace" {
  description = "Whether to create a new Azure Databricks workspace (true) or use existing (false)"
  type        = bool
  default     = true
}

variable "databricks_host" {
  description = "Azure Databricks workspace URL (e.g. https://adb-xxx.azuredatabricks.net). Required if create_workspace = false. If create_workspace = true, can be placeholder initially, then update with outputted workspace_url after first apply"
  type        = string
  default     = ""
}

variable "databricks_token" {
  description = "Databricks personal access token"
  type        = string
  sensitive   = true
}

variable "uc_catalog" {
  description = "Unity Catalog catalog name"
  type        = string
}

variable "uc_schema" {
  description = "Unity Catalog schema name"
  type        = string
}

variable "data_group" {
  description = "Unity Catalog principal (Azure AD group or user) to grant access"
  type        = string
  default     = "data_engineers"
}

# Azure Infrastructure Variables (required if create_workspace = true)
variable "azure_resource_group_name" {
  description = "Azure Resource Group name for Databricks workspace"
  type        = string
  default     = "rg-databricks-lab"
}

variable "azure_location" {
  description = "Azure region for Databricks workspace (e.g., eastus, westeurope)"
  type        = string
  default     = "eastus"
}

variable "databricks_workspace_name" {
  description = "Name of the Azure Databricks workspace"
  type        = string
  default     = "databricks-lab-workspace"
}

variable "databricks_sku" {
  description = "Azure Databricks SKU (premium or standard)"
  type        = string
  default     = "premium"
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID (for service principal authentication)"
  type        = string
  default     = ""
}

variable "azure_client_id" {
  description = "Azure Client ID (for service principal authentication)"
  type        = string
  default     = ""
}

variable "azure_client_secret" {
  description = "Azure Client Secret (for service principal authentication)"
  type        = string
  sensitive   = true
  default     = ""
}

# Optional: Azure Key Vault integration variables
# Uncomment if you want to use Azure Key Vault secret scope
# variable "azure_keyvault_resource_id" {
#   description = "Azure Key Vault resource ID (e.g., /subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/...)"
#   type        = string
#   default     = ""
# }
# 
# variable "azure_keyvault_dns_name" {
#   description = "Azure Key Vault DNS name (e.g., https://my-keyvault.vault.azure.net/)"
#   type        = string
#   default     = ""
# }

# Optional: Azure Storage integration variables
# Uncomment if you want to create external locations for Azure Data Lake Storage Gen2
# variable "azure_storage_connector_id" {
#   description = "Azure Storage connector (Managed Identity) resource ID"
#   type        = string
#   default     = ""
# }
# 
# variable "azure_storage_account_url" {
#   description = "Azure Storage Account URL (e.g., abfss://container@storageaccount.dfs.core.windows.net/)"
#   type        = string
#   default     = ""
# }

