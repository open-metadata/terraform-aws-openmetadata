module "db" {
  source = "./modules/rds"

  for_each = toset(local.opensearch_provisioner == "aws" ? ["this"] : [])

  app_namespace    = var.app_namespace
  kms_key_id       = var.kms_key_id
  eks_cluster_name = var.eks_cluster_name
  eks_nodes_sg_ids = var.eks_nodes_sg_ids
  vpc_id           = var.vpc_id
  subnet_ids       = var.subnet_ids
  db_config        = local.db
}
