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
  description = "Unity Catalog principal (group) to grant access"
  type        = string
  default     = "data_engineers"
}

