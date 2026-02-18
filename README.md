## Databricks DevOps Engineer Lab (Azure + Azure DevOps)

This repository contains a small lab for a Databricks DevOps Engineer role.

- **Infra** (`infra/`): Terraform configuration to create a Databricks cluster, notebook, job, Unity Catalog schema/table, and RBAC grants.
- **Notebooks** (`notebooks/`): A simple Databricks demo notebook.
- **Pipelines** (`pipelines/`): Azure DevOps YAML pipeline for CI (plan) and CD (apply).

See the interview brief or extended README for detailed instructions on how to configure variables (Databricks host, token, Unity Catalog catalog/schema, and Azure DevOps environment) and run the pipeline.

