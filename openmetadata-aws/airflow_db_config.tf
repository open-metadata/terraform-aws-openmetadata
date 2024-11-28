locals {
  airflow_db_provisioner = coalesce(try(var.airflow.db.provisioner, null), local.airflow_db_default_provisioner)
  airflow_db_secrets     = toset(local.airflow_db_provisioner == "helm" ? ["this"] : [])
  airflow_db_aws_config = local.airflow_db_provisioner == "aws" ? {
    aws = {
      backup_retention_period = coalesce(try(var.airflow.db.aws.backup_retention_period, null), local.airflow_db_aws_defaults.aws.backup_retention_period)
      backup_window           = coalesce(try(var.airflow.db.aws.backup_window, null), local.airflow_db_aws_defaults.aws.backup_window)
      identifier              = coalesce(try(var.airflow.db.aws.identifier, null), local.airflow_db_aws_defaults.aws.identifier)
      instance_class          = coalesce(try(var.airflow.db.aws.instance_class, null), local.airflow_db_aws_defaults.aws.instance_class)
      maintenance_window      = coalesce(try(var.airflow.db.aws.maintenance_window, null), local.airflow_db_aws_defaults.aws.maintenance_window)
      multi_az                = coalesce(try(var.airflow.db.aws.multi_az, null), local.airflow_db_aws_defaults.aws.multi_az)
      skip_final_snapshot     = coalesce(try(var.airflow.db.aws.skip_final_snapshot, null), local.airflow_db_aws_defaults.aws.skip_final_snapshot)
      deletion_protection     = coalesce(try(var.airflow.db.aws.deletion_protection, null), local.airflow_db_aws_defaults.aws.deletion_protection)
    }
    credentials = {
      username = coalesce(try(var.airflow.db.credentials.username, null), local.airflow_db_aws_defaults.credentials.username)
      password = {
        secret_ref = coalesce(try(var.airflow.db.credentials.password.secret_ref, null), local.airflow_db_aws_defaults.credentials.password.secret_ref)
        secret_key = coalesce(try(var.airflow.db.credentials.password.secret_key, null), local.airflow_db_aws_defaults.credentials.password.secret_key)
      }
    }
    db_name = coalesce(try(var.airflow.db.airflow_db_name, null), local.airflow_db_aws_defaults.db_name)
    engine = {
      name    = local.airflow_db_aws_defaults.engine.name
      version = coalesce(try(var.airflow.db.engine_version, null), local.airflow_db_aws_defaults.engine.version)
    }
    port         = coalesce(try(var.airflow.db.port, null), local.airflow_db_aws_defaults.port)
    storage_size = coalesce(try(var.airflow.db.storage_size, null), local.airflow_db_aws_defaults.storage_size)
  } : null

  airflow_db_existing_config = local.airflow_db_provisioner == "existing" ? var.airflow.db : null

  airflow_db_config = {
    helm     = local.shared_db_helm_config
    aws      = local.airflow_db_aws_config
    existing = local.airflow_db_existing_config
  }

  airflow_db = local.airflow_db_config[local.airflow_db_provisioner]
}
