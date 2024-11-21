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
    omd                            = local.omd
    opensearch                     = local.opensearch
    db                             = local.db
    airflow                        = local.airflow
  }
}
