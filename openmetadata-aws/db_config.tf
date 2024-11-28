locals {
  db_provisioner = coalesce(try(var.db.provisioner, null), local.db_default_provisioner)

  db_aws_config = local.db_provisioner == "aws" ? {
    aws = {
      identifier              = coalesce(try(var.db.aws.identifier, null), local.db_aws_defaults.aws.identifier)
      instance_class          = coalesce(try(var.db.aws.instance_class, null), local.db_aws_defaults.aws.instance_class)
      multi_az                = coalesce(try(var.db.aws.multi_az, null), local.db_aws_defaults.aws.multi_az)
      maintenance_window      = coalesce(try(var.db.aws.maintenance_window, null), local.db_aws_defaults.aws.maintenance_window)
      backup_window           = coalesce(try(var.db.aws.backup_window, null), local.db_aws_defaults.aws.backup_window)
      backup_retention_period = coalesce(try(var.db.aws.backup_retention_period, null), local.db_aws_defaults.aws.backup_retention_period)
      skip_final_snapshot     = coalesce(try(var.db.aws.skip_final_snapshot, null), local.db_aws_defaults.aws.skip_final_snapshot)
      deletion_protection     = coalesce(try(var.db.aws.deletion_protection, null), local.db_aws_defaults.aws.deletion_protection)
    }
    engine = {
      name    = local.db_aws_defaults.engine.name
      version = coalesce(try(var.db.engine_version, null), local.db_aws_defaults.engine.version)
    }
    port         = coalesce(try(var.db.port, null), local.db_aws_defaults.port)
    db_name      = coalesce(try(var.db.db_name, null), local.db_aws_defaults.db_name)
    storage_size = coalesce(try(var.db.storage_size, null), local.db_aws_defaults.storage_size)
    credentials = {
      username = coalesce(try(var.db.credentials.username, null), local.db_aws_defaults.credentials.username)
      password = {
        secret_ref = coalesce(try(var.db.credentials.password.secret_ref, null), local.db_aws_defaults.credentials.password.secret_ref)
        secret_key = coalesce(try(var.db.credentials.password.secret_key, null), local.db_aws_defaults.credentials.password.secret_key)
      }
    }
  } : null

  shared_db_helm_config = local.db_provisioner == "helm" || local.airflow_db_provisioner == "helm" ? {
    engine = {
      name = local.shared_db_helm_defaults.engine.name
    }
    port         = local.shared_db_helm_defaults.port
    storage_size = coalesce(try(var.db.storage_size, null), try(var.airflow.db.storage_size, null), local.shared_db_helm_defaults.storage_size)
  } : null

  db_existing_config = local.db_provisioner == "existing" ? var.db : null

  db_config = {
    helm     = local.shared_db_helm_config
    aws      = local.db_aws_config
    existing = local.db_existing_config
  }

  db = local.db_config[local.db_provisioner]
}
