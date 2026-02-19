# Databricks Lab – Deployment Guide

This project deploys **Azure Databricks** resources via **Terraform** and **Databricks Asset Bundle (DAB)**. Here is what the deployment does.

---

## What Gets Deployed

### 1. Azure Cloud (Terraform)

When `create_workspace = true`:

| Resource | Description |
|----------|-------------|
| **Azure Resource Group** | Container for the Databricks workspace (e.g., `rg-databricks-lab`) |
| **Azure Databricks Workspace** | Databricks workspace (Premium SKU) with Unity Catalog support |

**Region and subscription** are set in `terraform.tfvars` or pipeline variables (`AZURE_LOCATION`, `AZURE_SUBSCRIPTION_ID`).

---

### 2. Databricks Cluster (Terraform)

| Resource | Description |
|----------|-------------|
| **Cluster** `lab-dev-cluster` | Single-node cluster, `Standard_DS3_v2`, autotermination after 20 minutes, Delta Lake enabled |

---

### 3. Notebooks (Terraform + DAB)

| Source | Location | Description |
|--------|----------|-------------|
| **Terraform** | `/Shared/devops-lab/demo_notebook` | Uploads `notebooks/demo_notebook.py` |
| **DAB** | Workspace paths defined in bundle | Syncs `bundle/resources/notebooks/` into the workspace |

---

### 4. Databricks Jobs (Terraform + DAB)

| Job | Description |
|-----|-------------|
| **devops-lab-demo-job** | Runs the demo notebook daily at 12:00 UTC, passes `catalog`, `schema`, and `input` parameters |

- **Terraform**: Uses the cluster `lab-dev-cluster`
- **DAB**: Uses its own job cluster; DAB deploy overwrites the job when both are used

---

### 5. Unity Catalog (Terraform)

| Resource | Description |
|----------|-------------|
| **Schema** | `{catalog}.{schema}` (e.g., `main.devops_lab`) |
| **Table** | `{catalog}.{schema}.lab_events` – managed table with `id` (INT) and `event` (STRING) |
| **RBAC Grants** | Grants `USAGE`, `SELECT` on schema and `SELECT` on table to the `data_group` (e.g., `data_engineers`) |

---

## Deployment Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│  CI (on push to main)                                                    │
├─────────────────────────────────────────────────────────────────────────┤
│  • Terraform: validate, plan                                             │
│  • DAB: validate bundle                                                  │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  CD (after CI, main branch only)                                         │
├─────────────────────────────────────────────────────────────────────────┤
│  1. Terraform apply                                                      │
│     • Create workspace (if new) → Get URL → Full apply                    │
│     • Creates: Azure RG, workspace, cluster, notebook, job, UC, RBAC     │
│  2. DAB deploy                                                           │
│     • Sync notebooks                                                     │
│     • Deploy/update job                                                  │
│  3. DAB run (optional)                                                   │
│     • Trigger devops-lab-demo-job                                        │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Two Deployment Paths

### Option A: Terraform + DAB (Full Stack)

Use `pipelines/azure-devops-ci-cd.yml` to:

- Create Azure Databricks workspace (optional)
- Create cluster, notebook, job, Unity Catalog schema/table, and RBAC
- Deploy DAB bundle (notebooks and job)

### Option B: DAB Only (Existing Workspace)

Use `pipelines/dab-only-pipeline.yml` when the workspace already exists:

- Validate and deploy DAB bundle
- Sync notebooks and deploy/update the job

---

## Prerequisites

- **Azure**: Subscription, Service Principal (or Azure CLI login)
- **Databricks**: Personal Access Token (PAT)
- **Pipeline variables**: `DATABRICKS_HOST`, `DATABRICKS_TOKEN`, `AZURE_SUBSCRIPTION_ID`, `AZURE_LOCATION`, `UC_CATALOG`, `UC_SCHEMA`, and ARM credentials if creating a new workspace

---

## Resulting Environment

After deployment:

- **Workspace**: Azure Databricks Premium workspace in the chosen region
- **Cluster**: `lab-dev-cluster` for ad‑hoc and Terraform-managed jobs
- **Notebook**: Demo notebook that writes sample data into a Unity Catalog table
- **Job**: `devops-lab-demo-job` scheduled daily
- **Unity Catalog**: Schema and table `lab_events` with RBAC grants
