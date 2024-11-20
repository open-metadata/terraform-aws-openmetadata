locals {
  omd_config     = local.omd_defaults
  omd_db_secrets = toset(local.db_provisioner == "helm" ? ["this"] : [])

  omd_db_host = {
    existing = try(var.db.host, null)
    aws      = try(module.db["this"].db_instance_address, null)
    helm     = "mysql"
  }

  omd = merge(local.omd_config, {
    db_host = local.omd_db_host[local.db_provisioner]
  })

  omd_template_vars = {
    opensearch_provisioner = local.opensearch_provisioner
    db_provisioner         = local.db_provisioner
    db_engine              = local.db.engine.name
    omd                    = local.omd
    opensearch             = local.opensearch
    db                     = local.db
    airflow                = local.airflow
  }

  #  omd_template = [
  #    templatefile("${path.module}/helm-dependencies/openmetadata_config.tftpl", local.omd_template_vars)
  #  ]
}
