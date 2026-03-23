# https://docs.open-metadata.org/latest/quick-start/local-kubernetes-deployment#2.-create-kubernetes-secrets-required-for-helm-charts

resource "random_bytes" "airflow_fernet_key" {
  for_each = toset(local.airflow_provisioner == "helm" ? ["this"] : [])
  length   = 32
}

resource "kubernetes_secret_v1" "airflow_fernet_key" {
  for_each = toset(local.airflow_provisioner == "helm" ? ["this"] : [])

  metadata {
    name      = "openmetadata-deps-fernet-key"
    namespace = var.app_namespace
  }

  data = {
    fernet-key = replace(replace(random_bytes.airflow_fernet_key[each.key].base64, "+", "-"), "/", "_")
  }
}

resource "random_password" "airflow_auth" {
  for_each = toset(local.airflow_provisioner == "helm" ? ["this"] : [])

  length      = 24
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  special     = false
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

locals {
  airflow_db_connection_uri = local.airflow_db_provisioner == "aws" ? format(
    "postgresql+psycopg2://%s:%s@%s:%s/%s",
    try(local.airflow_db.credentials.username, ""),
    try(module.airflow_db["this"].db_password, ""),
    try(module.airflow_db["this"].db_instance_address, ""),
    try(tostring(local.airflow_db.port), ""),
    try(local.airflow_db.db_name, "")
  ) : ""
}

resource "kubernetes_secret_v1" "airflow_db_connection" {
  for_each = toset(local.airflow_db_provisioner == "aws" ? ["this"] : [])

  metadata {
    name      = "airflow-db-connection"
    namespace = var.app_namespace
  }

  data = {
    connection = local.airflow_db_connection_uri
  }
}
