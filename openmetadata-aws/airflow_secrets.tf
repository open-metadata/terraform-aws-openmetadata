# https://docs.open-metadata.org/latest/quick-start/local-kubernetes-deployment#2.-create-kubernetes-secrets-required-for-helm-charts

resource "random_password" "airflow_auth" {
  for_each = toset(local.airflow_provisioner == "helm" ? ["this"] : [])

  length      = 16
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

resource "kubernetes_secret_v1" "airflow_auth" {
  for_each = toset(local.airflow_provisioner == "helm" ? ["this"] : [])

  metadata {
    name      = local.airflow.credentials.password.secret_ref
    namespace = local.omd.namespace
  }

  data = {
    (local.airflow.credentials.password.secret_key) = try(random_password.airflow_auth[each.key].result, null)
  }
}

resource "kubernetes_secret_v1" "airflow_db_credentials" {
  for_each = local.airflow_db_secrets

  metadata {
    name      = "airflow-mysql-secrets"
    namespace = var.app_namespace
  }

  data = {
    "airflow-mysql-password" = "airflow_pass"
  }
}
