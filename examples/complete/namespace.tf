# K8s namespace for OpenMetadata

locals {
  namespace = kubernetes_namespace.app.metadata[0].name
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "openmetadata"
  }
}
