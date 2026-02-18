############################
# Azure Databricks Cluster
############################

resource "databricks_cluster" "lab_cluster" {
  cluster_name            = "lab-dev-cluster"
  spark_version           = "14.3.x-scala2.12"
  node_type_id            = "Standard_DS3_v2" # Azure VM size (DS = Premium SSD)
  num_workers             = 1
  autotermination_minutes = 20

  # Azure Databricks specific Spark configurations
  spark_conf = {
    "spark.databricks.cluster.profile"        = "singleNode"
    "spark.databricks.delta.preview.enabled"  = "true"
    "spark.databricks.repl.allowedLanguages"  = "python,sql"
  }

  # Enable cluster log delivery to Azure Storage (optional - uncomment if needed)
  # cluster_log_conf {
  #   dbfs {
  #     destination = "dbfs:/cluster-logs"
  #   }
  # }
}

############################
# Azure Key Vault Secret Scope (Optional)
# Uncomment and configure if you want to use Azure Key Vault for secrets
############################

# resource "databricks_secret_scope" "azure_keyvault" {
#   name = "azure-keyvault-scope"
# 
#   keyvault_metadata {
#     resource_id = var.azure_keyvault_resource_id  # e.g., /subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/...
#     dns_name    = var.azure_keyvault_dns_name     # e.g., https://my-keyvault.vault.azure.net/
#   }
# }

############################
# Azure Data Lake Storage Gen2 External Location (Optional)
# Uncomment if you want to create an external location for Azure Data Lake Storage
############################

# resource "databricks_storage_credential" "adls_credential" {
#   name = "adls-credential"
#   azure_managed_identity {
#     access_connector_id = var.azure_storage_connector_id
#   }
#   comment = "Azure Managed Identity credential for ADLS Gen2"
# }
# 
# resource "databricks_external_location" "adls_external" {
#   name            = "adls-external-location"
#   url             = var.azure_storage_account_url  # e.g., abfss://container@storageaccount.dfs.core.windows.net/
#   credential_name = databricks_storage_credential.adls_credential.name
#   comment         = "External location for Azure Data Lake Storage Gen2"
# }

############################
# Notebook (upload from repo)
############################

resource "databricks_workspace_file" "demo_notebook" {
  path      = "/Shared/devops-lab/demo_notebook"
  source    = "${path.module}/../notebooks/demo_notebook.py"
  format    = "SOURCE"
  overwrite = true
}

############################
# Azure Databricks Job
############################

resource "databricks_job" "demo_job" {
  name = "devops-lab-demo-job"

  existing_cluster_id = databricks_cluster.lab_cluster.id

  notebook_task {
    notebook_path = databricks_workspace_file.demo_notebook.path

    base_parameters = {
      input = "from-terraform-job"
    }
  }

  schedule {
    quartz_cron_expression = "0 0 12 * * ?" # daily at noon UTC
    timezone_id            = "UTC"
    pause_status           = "UNPAUSED"
  }

  # Azure Databricks job notification (optional - uncomment if needed)
  # email_notifications {
  #   on_success = [var.notification_email]
  #   on_failure = [var.notification_email]
  # }
}

############################
# Azure Databricks Unity Catalog: schema + table
# Unity Catalog on Azure Databricks provides centralized governance
############################

resource "databricks_schema" "lab_schema" {
  name         = var.uc_schema
  catalog_name = var.uc_catalog
  comment      = "Schema for DevOps lab on Azure Databricks"
}

resource "databricks_table" "lab_table" {
  name         = "lab_events"
  catalog_name = var.uc_catalog
  schema_name  = databricks_schema.lab_schema.name
  table_type   = "MANAGED" # Managed tables are stored in Unity Catalog metastore (Azure managed)
  comment      = "Sample table for DevOps lab on Azure Databricks"

  columns {
    name = "id"
    type = "INT"
  }

  columns {
    name = "event"
    type = "STRING"
  }
}

############################
# Azure Databricks RBAC grants
# Unity Catalog RBAC integrates with Azure Active Directory (Azure AD)
# Groups/users referenced here should exist in Azure AD
############################

resource "databricks_grants" "schema_grants" {
  schema = "${var.uc_catalog}.${databricks_schema.lab_schema.name}"

  grant {
    principal  = var.data_group # Azure AD group or user
    privileges = ["USAGE", "SELECT"]
  }
}

resource "databricks_grants" "table_grants" {
  table = "${var.uc_catalog}.${databricks_schema.lab_schema.name}.${databricks_table.lab_table.name}"

  grant {
    principal  = var.data_group # Azure AD group or user
    privileges = ["SELECT"]
  }
}

