# OpenMetadata deployment

module "deployment" {
  source = "./modules/openmetadata-deployment"

  namespace          = local.omd.namespace
  helm_chart_version = local.omd.helm_chart_version
  helm_values        = local.omd_template_vars
}

# OpenMetadata dependencies

module "openmetadata_deps" {
  source = "./modules/openmetadata-dependencies"

  namespace          = local.omd.namespace
  helm_chart_version = local.omd.helm_chart_version
  helm_values        = local.omd_dependencies_template_vars
}

# OpenMetadata RDS instance (optional)

module "db" {
  source = "./modules/rds"

  for_each = toset(local.db_provisioner == "aws" ? ["this"] : [])

  namespace        = var.app_namespace
  kms_key_id       = var.kms_key_id
  eks_nodes_sg_ids = var.eks_nodes_sg_ids
  vpc_id           = var.vpc_id
  subnet_ids       = var.subnet_ids
  db_config        = local.db
}

# Airflow RDS instance (optional)

module "airflow_db" {
  source = "./modules/rds"

  for_each = toset(local.airflow_db_provisioner == "aws" ? ["this"] : [])

  namespace        = var.app_namespace
  kms_key_id       = var.kms_key_id
  eks_nodes_sg_ids = var.eks_nodes_sg_ids
  vpc_id           = var.vpc_id
  subnet_ids       = var.subnet_ids
  db_config        = local.airflow_db
}

# Airflow EFS volumes (optional)

module "airflow_efs" {
  source = "./modules/airflow-efs"

  for_each = toset(local.airflow_provisioner == "helm" ? ["this"] : [])

  airflow          = local.airflow
  enable_helpers   = true
  eks_nodes_sg_ids = var.eks_nodes_sg_ids
  namespace        = var.app_namespace
  subnet_ids       = var.subnet_ids
  vpc_id           = var.vpc_id
}

# OpenSearch domain (optional)

module "opensearch" {
  source = "./modules/opensearch"

  for_each = toset(local.opensearch_provisioner == "aws" ? ["this"] : [])

  namespace        = var.app_namespace
  kms_key_id       = var.kms_key_id
  eks_nodes_sg_ids = var.eks_nodes_sg_ids
  vpc_id           = var.vpc_id
  subnet_ids       = var.subnet_ids
  opensearch       = local.opensearch
}
