# Terraform Execution Order Explanation

## How Terraform Processes Files

**Important**: Terraform reads ALL `.tf` files in the `infra/` directory together. There is **NO file execution order** - all files are processed as one configuration.

## Execution Sequence

When you run `terraform apply`, Terraform follows this sequence:

### 1. **Provider Configuration** (from `provider.tf`)
   - **Runs FIRST** - before any resources
   - Configures `azurerm` provider (for Azure)
   - Configures `databricks` provider (needs workspace URL upfront)
   - **Problem**: Databricks provider needs workspace URL, but workspace doesn't exist yet if `create_workspace=true`

### 2. **Resource Planning** (from all `.tf` files)
   - Terraform analyzes dependencies
   - Resources in `azure_infrastructure.tf`:
     - `azurerm_resource_group.databricks` (no dependencies)
     - `azurerm_databricks_workspace.this` (depends on resource group)
   - Resources in `main.tf`:
     - All Databricks resources (cluster, notebook, job, UC, RBAC)
     - These depend on Databricks provider being configured

### 3. **Resource Application** (dependency order)
   - **First**: Azure Resource Group (if `create_workspace=true`)
   - **Second**: Azure Databricks Workspace (if `create_workspace=true`)
   - **Third**: Databricks resources from `main.tf` (cluster, notebook, job, etc.)

## The Challenge: Provider Needs URL Before Workspace Exists

**The Problem:**
```
Provider (needs URL) → Workspace (provides URL) → Databricks Resources
```

**The Solution: Two-Stage Apply**

### Stage 1: Create Azure Infrastructure
```bash
terraform apply -target=azurerm_resource_group.databricks -target=azurerm_databricks_workspace.this \
  -var="create_workspace=true" \
  -var="databricks_host=https://placeholder.azuredatabricks.net" \
  ...
```

**What happens:**
- ✅ Azure Resource Group created
- ✅ Azure Databricks Workspace created
- ⚠️ Databricks provider uses placeholder URL (doesn't matter for Azure resources)
- ⏭️ Databricks resources skipped (due to `-target`)

### Stage 2: Create Databricks Resources
```bash
# Get workspace URL from output
terraform output databricks_workspace_url

# Apply with actual workspace URL
terraform apply \
  -var="create_workspace=true" \
  -var="databricks_host=<actual-workspace-url>" \
  ...
```

**What happens:**
- ✅ Databricks provider configured with actual workspace URL
- ✅ All Databricks resources created (cluster, notebook, job, UC, RBAC)

## Alternative: Single Apply (When Using Existing Workspace)

If `create_workspace=false`:
```bash
terraform apply \
  -var="create_workspace=false" \
  -var="databricks_host=https://adb-xxx.azuredatabricks.net" \
  ...
```

**What happens:**
- ✅ Databricks provider configured with existing workspace URL
- ✅ All Databricks resources created in one go
- ⏭️ No Azure infrastructure created

## Summary

| Scenario | Files Processed | Execution Order |
|----------|----------------|-----------------|
| `create_workspace=true` | All `.tf` files | **Two-stage**: Azure infra first, then Databricks resources |
| `create_workspace=false` | All `.tf` files | **Single-stage**: Databricks resources only |

**Key Point**: Terraform processes all files together, but **providers are configured before resources**, which requires the two-stage approach when creating a new workspace.
