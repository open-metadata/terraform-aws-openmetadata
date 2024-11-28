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
