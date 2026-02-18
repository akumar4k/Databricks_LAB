############################
# Cluster
############################

resource "databricks_cluster" "lab_cluster" {
  cluster_name            = "lab-dev-cluster"
  spark_version           = "14.3.x-scala2.12"
  node_type_id            = "Standard_DS3_v2"
  num_workers             = 1
  autotermination_minutes = 20
}

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
# Job that runs notebook
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
}

############################
# Unity Catalog: schema + table
############################

resource "databricks_schema" "lab_schema" {
  name         = var.uc_schema
  catalog_name = var.uc_catalog
  comment      = "Schema for DevOps lab"
}

resource "databricks_table" "lab_table" {
  name         = "lab_events"
  catalog_name = var.uc_catalog
  schema_name  = databricks_schema.lab_schema.name
  table_type   = "MANAGED"
  comment      = "Sample table for DevOps lab"

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
# RBAC grants
############################

resource "databricks_grants" "schema_grants" {
  schema = "${var.uc_catalog}.${databricks_schema.lab_schema.name}"

  grant {
    principal  = var.data_group
    privileges = ["USAGE", "SELECT"]
  }
}

resource "databricks_grants" "table_grants" {
  table = "${var.uc_catalog}.${databricks_schema.lab_schema.name}.${databricks_table.lab_table.name}"

  grant {
    principal  = var.data_group
    privileges = ["SELECT"]
  }
}

