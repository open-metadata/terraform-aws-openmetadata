locals {
  template = [
    templatefile("${path.module}/helm_values.tftpl", var.helm_values)
  ]
}

resource "helm_release" "openmetadata" {
  name       = "openmetadata"
  repository = "https://helm.open-metadata.org"
  chart      = "openmetadata"
  version    = var.helm_chart_version
  namespace  = var.namespace
  wait       = false
  values     = local.template

  # Ensure proper cleanup during destroy operations
  lifecycle {
    create_before_destroy = false  # Don't create new release before destroying old one
  }
}
