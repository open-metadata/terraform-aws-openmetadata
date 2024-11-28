module "openmetadata_deps" {
  source = "github.com/open-metadata/openmetadata-terraform//submodules/openmetadata-dependencies?ref=1.5.12"

  namespace          = local.omd.namespace
  helm_chart_version = local.omd.helm_chart_version
  helm_values        = local.omd_dependencies_template_vars
}
