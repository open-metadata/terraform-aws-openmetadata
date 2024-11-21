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
