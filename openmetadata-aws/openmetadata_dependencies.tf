module "openmetadata_deps" {
  source = "../submodules/openmetadata-dependencies"

  namespace          = local.omd.namespace
  helm_chart_version = local.omd.helm_chart_version
  helm_values        = local.omd_dependencies_template_vars
}
