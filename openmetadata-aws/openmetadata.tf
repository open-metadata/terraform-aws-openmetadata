module "deployment" {
  source = "../submodules/openmetadata-deployment"

  namespace          = local.omd.namespace
  helm_chart_version = local.omd.helm_chart_version
  helm_values        = local.omd_template_vars
}
