# https://docs.open-metadata.org/latest/quick-start/local-kubernetes-deployment#2.-create-kubernetes-secrets-required-for-helm-charts

resource "kubernetes_secret_v1" "db_credentials" {
  for_each = local.omd_db_secrets

  metadata {
    name      = "mysql-secrets"
    namespace = var.app_namespace
  }

  data = {
    "openmetadata-mysql-password" = "openmetadata_password"
  }
}

