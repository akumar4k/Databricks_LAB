terraform {
  required_version = ">= 1.5.0"

  required_providers {
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

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}

