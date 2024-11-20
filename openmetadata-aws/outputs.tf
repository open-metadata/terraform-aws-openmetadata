output "db_address" {
  value = local.db_provisioner == "aws" ? module.db["this"].db_instance_address : null
}

output "airflow_db_address" {
  value = local.airflow_db_provisioner == "aws" ? module.airflow_db["this"].db_instance_address : null
}

output "opensearch_endpoint" {
  value = local.opensearch_provisioner == "aws" ? module.opensearch["this"].endpoint : null
}

output "omd_template" {
  value = module.deployment.helm_template
}

output "omd_deps_template" {
  value = module.openmetadata_deps.helm_template
}
