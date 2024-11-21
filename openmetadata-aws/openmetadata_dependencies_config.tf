locals {
  omd_dependencies_config = {
    opensearch_storage_class_enabled = try(var.opensearch.storage_class, null) != null
    airflow_enabled                  = local.airflow_provisioner == "helm" ? true : false
    mysql_enabled                    = local.db_provisioner == "helm" || local.airflow_db_provisioner == "helm" ? true : false
    opensearch_enabled               = local.opensearch_provisioner == "helm" ? true : false
    opensearch_storage_class_enabled = try(var.opensearch.storage_class, null) != null ? true : false
  }

  airflow_db_host = {
    existing = try(var.airflow.db.host, null)
    aws      = try(module.airflow_db["this"].db_instance_address, null)
    helm     = "mysql"
  }

  omd_dependencies = {
    airflow_db_host = local.airflow_db_host[local.airflow_db_provisioner]
  }

  omd_dependencies_template_vars = {
    airflow_enabled                  = local.omd_dependencies_config.airflow_enabled
    mysql_enabled                    = local.omd_dependencies_config.mysql_enabled
    opensearch_enabled               = local.omd_dependencies_config.opensearch_enabled
    opensearch_storage_class_enabled = local.omd_dependencies_config.opensearch_storage_class_enabled

    airflow_db_provisioner = local.airflow_db_provisioner
    airflow_provisioner    = local.airflow_provisioner
    opensearch_provisioner = local.opensearch_provisioner

    omd              = local.omd
    omd_dependencies = local.omd_dependencies

    airflow    = local.airflow
    mysql      = local.shared_db_helm_config
    opensearch = local.opensearch
  }
}
