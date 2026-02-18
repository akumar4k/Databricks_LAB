## Databricks DevOps Engineer Lab (Azure + Azure DevOps)

This repository contains a small lab for a Databricks DevOps Engineer role.

- **Infra** (`infra/`): Terraform configuration that can:
  - **Create Azure Databricks workspace** (Azure infrastructure) - NEW!
  - **Create Databricks resources** within the workspace: cluster, notebook, job, Unity Catalog schema/table, and RBAC grants
- **Notebooks** (`notebooks/`): A simple Databricks demo notebook.
- **Pipelines** (`pipelines/`): Azure DevOps YAML pipeline for CI (plan) and CD (apply).
- **Security Scanning** (`.pre-commit-config.yaml`): Pre-commit hooks for Terraform formatting, validation, and security scanning with **tfsec**, **Checkov** (including Databricks framework), and custom Databricks security validation.

### Two Deployment Modes

1. **Create New Azure Databricks Workspace** (`create_workspace = true`):
   - Creates Azure Resource Group
   - Creates Azure Databricks workspace
   - Then creates all Databricks resources within it

2. **Use Existing Workspace** (`create_workspace = false`):
   - Uses existing Azure Databricks workspace
   - Only creates Databricks resources (cluster, notebook, job, UC, RBAC)

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

### Quick Start

#### Option 1: Create New Azure Databricks Workspace

**Two-stage process** (required because Databricks provider needs workspace URL upfront):

**Stage 1: Create Azure Databricks Workspace**
```bash
cd infra

terraform init

# First, create only the Azure workspace (use placeholder for databricks_host)
terraform apply -target=azurerm_resource_group.databricks -target=azurerm_databricks_workspace.this \
  -var="create_workspace=true" \
  -var="azure_resource_group_name=rg-databricks-lab" \
  -var="azure_location=eastus" \
  -var="databricks_workspace_name=databricks-lab-workspace" \
  -var="databricks_host=https://placeholder.azuredatabricks.net" \
  -var="databricks_token=<your-pat-token>" \
  -var="uc_catalog=main" \
  -var="uc_schema=devops_lab"

# Note the workspace URL from output
terraform output databricks_workspace_url
```

**Stage 2: Create Databricks Resources**
```bash
# Now apply with the actual workspace URL from Stage 1 output
terraform apply \
  -var="create_workspace=true" \
  -var="azure_resource_group_name=rg-databricks-lab" \
  -var="azure_location=eastus" \
  -var="databricks_workspace_name=databricks-lab-workspace" \
  -var="databricks_host=<workspace-url-from-stage1-output>" \
  -var="databricks_token=<your-pat-token>" \
  -var="uc_catalog=main" \
  -var="uc_schema=devops_lab"
```

**Note**: For Azure authentication, you can use:
- `az login` (Azure CLI) - recommended
- Environment variables: `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`
- Service Principal via variables

#### Option 2: Use Existing Azure Databricks Workspace

```bash
cd infra

terraform init

terraform plan \
  -var="create_workspace=false" \
  -var="databricks_host=https://adb-xxxxxxxx.azuredatabricks.net" \
  -var="databricks_token=<your-pat-token>" \
  -var="uc_catalog=main" \
  -var="uc_schema=devops_lab"

terraform apply -auto-approve \
  -var="create_workspace=false" \
  -var="databricks_host=https://adb-xxxxxxxx.azuredatabricks.net" \
  -var="databricks_token=<your-pat-token>" \
  -var="uc_catalog=main" \
  -var="uc_schema=devops_lab"
```

### What Gets Created

**If `create_workspace = true`:**
- Azure Resource Group
- Azure Databricks Workspace (Premium SKU with Unity Catalog support)
- All Databricks resources (cluster, notebook, job, Unity Catalog schema/table, RBAC)

**If `create_workspace = false`:**
- Only Databricks resources (cluster, notebook, job, Unity Catalog schema/table, RBAC)

See the interview brief or extended README for detailed instructions on how to configure variables and run the Azure DevOps pipeline.

