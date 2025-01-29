# OpenMetadata AWS module

module "app" {
  source  = "open-metadata/openmetadata/aws"
  version = "1.6.2"

  airflow  = var.airflow
  env_from = local.env_from
  extra_envs = {
    "ELASTICSEARCH_BATCH_SIZE" = 250
  }
  app_namespace    = local.namespace
  app_version      = var.app_version
  db               = var.db
  eks_nodes_sg_ids = [local.eks_nodes_sg_id]
  kms_key_id       = local.kms_key_id
  opensearch       = var.opensearch
  subnet_ids       = local.subnet_ids
  vpc_id           = local.vpc_id

  depends_on = [
    aws_eks_cluster.openmetadata,
    aws_kms_alias.this,
    kubernetes_namespace.app,
    kubernetes_secret_v1.env_from_secret,
    module.vpc
  ]
}

# Extra environment variables from Kubernets secret

locals {
  env_from = [
    kubernetes_secret_v1.env_from_secret.metadata.0.name
  ]
}

resource "kubernetes_secret_v1" "env_from_secret" {
  metadata {
    name      = "env-from"
    namespace = local.namespace
  }
  data = {
    "PIPELINE_SERVICE_IP_INFO_ENABLED" = true
  }
}
