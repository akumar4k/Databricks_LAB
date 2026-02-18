#!/bin/bash
# Databricks-specific security validation script
# This script checks for common Databricks security best practices

set -e

echo "🔍 Running Databricks security validation..."

ERRORS=0

# Check if infra directory exists
if [ ! -d "infra" ]; then
  echo "❌ Error: infra directory not found"
  exit 1
fi

# Check for hardcoded tokens/secrets in Terraform files
echo "Checking for hardcoded secrets..."
if grep -r "token.*=.*[\"'][^\"']*[\"']" infra/*.tf 2>/dev/null | grep -v "var.databricks_token"; then
  echo "⚠️  Warning: Potential hardcoded token found in Terraform files"
  ERRORS=$((ERRORS + 1))
fi

# Check for cluster data security mode (should use SINGLE_USER or NONE for production)
echo "Checking cluster data security configuration..."
if ! grep -q "data_security_mode\|single_user_name\|spark_conf" infra/main.tf 2>/dev/null; then
  echo "⚠️  Warning: Consider specifying data_security_mode for clusters"
fi

# Check for autotermination on clusters
echo "Checking cluster autotermination..."
if ! grep -q "autotermination_minutes" infra/main.tf 2>/dev/null; then
  echo "⚠️  Warning: Consider setting autotermination_minutes to prevent cost overruns"
fi

# Check for Unity Catalog usage (good practice)
echo "Checking Unity Catalog usage..."
if grep -q "databricks_schema\|databricks_table\|databricks_catalog" infra/main.tf 2>/dev/null; then
  echo "✅ Unity Catalog resources detected (good practice)"
else
  echo "⚠️  Warning: No Unity Catalog resources found. Consider using Unity Catalog for data governance"
fi

# Check for RBAC grants
echo "Checking RBAC configuration..."
if grep -q "databricks_grants" infra/main.tf 2>/dev/null; then
  echo "✅ RBAC grants detected (good practice)"
else
  echo "⚠️  Warning: No RBAC grants found. Consider implementing proper access controls"
fi

# Check for job email notifications (good for monitoring)
echo "Checking job notification configuration..."
if ! grep -q "email_notifications\|webhook_notifications" infra/main.tf 2>/dev/null; then
  echo "ℹ️  Info: Consider adding email/webhook notifications for job failures"
fi

if [ $ERRORS -eq 0 ]; then
  echo "✅ Databricks security validation completed"
  exit 0
else
  echo "❌ Databricks security validation found $ERRORS issue(s)"
  exit 1
fi
