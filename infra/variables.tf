variable "databricks_host" {
  description = "Azure Databricks workspace URL (e.g. https://adb-xxx.azuredatabricks.net)"
  type        = string
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

