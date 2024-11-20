locals {
  airflow_provisioner = coalesce(try(var.airflow.provisioner, null), local.airflow_default_provisioner)

  airflow_helm_config = local.airflow_provisioner == "helm" ? {

    credentials = {
      username = coalesce(try(var.airflow.credentials.username, null), local.airflow_helm_defaults.credentials.username)
      password = {
        secret_ref = coalesce(try(var.airflow.credentials.password.secret_ref, null), local.airflow_helm_defaults.credentials.password.secret_ref)
        secret_key = coalesce(try(var.airflow.credentials.password.secret_key, null), local.airflow_helm_defaults.credentials.password.secret_key)
      }
    }
    db       = local.airflow_db
    endpoint = coalesce(try(var.airflow.endpoint, null), local.airflow_helm_defaults.endpoint)
    pvc = {
      logs = local.airflow_helm_defaults.pvc.logs
      dags = local.airflow_helm_defaults.pvc.dags
    }
    storage = {
      logs = coalesce(try(var.airflow.storage.logs, null), local.airflow_helm_defaults.storage.logs)
      dags = coalesce(try(var.airflow.storage.dags, null), local.airflow_helm_defaults.storage.dags)
    }
    subpath = {
      logs = local.airflow_helm_defaults.subpath.logs
      dags = local.airflow_helm_defaults.subpath.dags
    }
  } : null

  airflow_existing_config = local.airflow_provisioner == "existing" ? {
    credentials = var.airflow.credentials
    endpoint    = var.airflow.endpoint
  } : null

  airflow_config = {
    helm     = local.airflow_helm_config
    existing = local.airflow_existing_config
  }

  airflow = local.airflow_config[local.airflow_provisioner]
}
