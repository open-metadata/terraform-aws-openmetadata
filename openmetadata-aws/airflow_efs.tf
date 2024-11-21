module "airflow_efs" {
  source = "./modules/airflow-efs"

  for_each = toset(local.airflow_provisioner == "helm" ? ["this"] : [])

  airflow        = local.airflow
  enable_helpers = true
  namespace      = var.app_namespace
  subnet_ids     = var.subnet_ids
  vpc_id         = var.vpc_id
}
