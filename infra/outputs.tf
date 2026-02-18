output "cluster_id" {
  value       = databricks_cluster.lab_cluster.id
  description = "ID of the created Databricks cluster"
}

output "job_id" {
  value       = databricks_job.demo_job.id
  description = "ID of the demo job"
}

output "uc_table_fqn" {
  value       = "${var.uc_catalog}.${databricks_schema.lab_schema.name}.${databricks_table.lab_table.name}"
  description = "Fully qualified name of the Unity Catalog table"
}

