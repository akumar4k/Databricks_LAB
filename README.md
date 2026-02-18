## Databricks DevOps Engineer Lab (Azure + Azure DevOps)

This repository contains a small lab for a Databricks DevOps Engineer role.

- **Infra** (`infra/`): Terraform configuration to create a Databricks cluster, notebook, job, Unity Catalog schema/table, and RBAC grants.
- **Notebooks** (`notebooks/`): A simple Databricks demo notebook.
- **Pipelines** (`pipelines/`): Azure DevOps YAML pipeline for CI (plan) and CD (apply).
- **Security Scanning** (`.pre-commit-config.yaml`): Pre-commit hooks for Terraform formatting, validation, and security scanning with **tfsec**, **Checkov** (including Databricks framework), and custom Databricks security validation.

### Security Scanning

This lab includes comprehensive security scanning:

- **tfsec**: Terraform-specific security scanner
- **Checkov**: Multi-framework security scanner (Terraform + Databricks framework)
- **Custom Databricks validation** (`scripts/validate_databricks_security.sh`): Checks for Databricks-specific security best practices:
  - Hardcoded secrets detection
  - Cluster data security mode configuration
  - Autotermination settings
  - Unity Catalog usage
  - RBAC grants
  - Job notification configuration

To use pre-commit hooks locally:

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

See the interview brief or extended README for detailed instructions on how to configure variables (Databricks host, token, Unity Catalog catalog/schema, and Azure DevOps environment) and run the pipeline.

