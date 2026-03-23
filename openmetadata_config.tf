locals {
  omd_config     = local.omd_defaults
  omd_db_secrets = toset(local.db_provisioner == "helm" ? ["this"] : [])

  omd_db_host = {
    existing = try(var.db.host, null)
    aws      = try(module.db["this"].db_instance_address, null)
    helm     = "mysql"
  }

  omd_opensearch_host = {
    existing = try(var.opensearch.host, null)
    aws      = try(module.opensearch["this"].endpoint, null)
    helm     = "opensearch"
  }

  omd = merge(local.omd_config, {
    db_host         = local.omd_db_host[local.db_provisioner]
    opensearch_host = local.omd_opensearch_host[local.opensearch_provisioner]
  })

  omd_template_vars = {
    opensearch_provisioner         = local.opensearch_provisioner
    opensearch_credentials_enabled = local.opensearch_credentials_enabled
    db_provisioner                 = local.db_provisioner
    db_engine                      = local.db.engine.name
    airflow_provisioner            = local.airflow_provisioner
    omd                            = local.omd
    opensearch                     = local.opensearch
    db                             = local.db
    airflow = {
      endpoint = try(local.airflow.endpoint, "")
      credentials = {
        username = try(local.airflow.credentials.username, "")
        password = {
          secret_ref = try(local.airflow.credentials.password.secret_ref, "")
          secret_key = try(local.airflow.credentials.password.secret_key, "")
        }
      }
    }
  }

  omd_extra_helm_values = var.openmetadata_helm_values
}
