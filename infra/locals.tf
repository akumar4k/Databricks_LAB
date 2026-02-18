############################
# Local values for workspace URL resolution
############################

locals {
  # Determine workspace URL for provider:
  # - If create_workspace=true: Use var.databricks_host (must be set, can be placeholder initially)
  # - If create_workspace=false: Use var.databricks_host or data source
  # 
  # IMPORTANT: Providers are evaluated BEFORE resources, so we can't reference
  # azurerm_databricks_workspace.this[0].workspace_url here.
  # Solution: Two-stage apply when create_workspace=true:
  #   Stage 1: Create workspace with placeholder URL
  #   Stage 2: Update databricks_host with actual URL from output
  databricks_workspace_url = var.create_workspace ? (
    # When creating workspace, use var (placeholder initially, then actual URL after Stage 1)
    var.databricks_host != "" ? var.databricks_host : "https://placeholder.azuredatabricks.net"
  ) : (
    # When using existing workspace, try data source first, fallback to var
    var.databricks_host != "" ? var.databricks_host : (
      length(data.azurerm_databricks_workspace.existing) > 0 ? data.azurerm_databricks_workspace.existing[0].workspace_url : ""
    )
  )
}
