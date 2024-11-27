data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "tls_certificate" "cluster" {
  url = one(aws_eks_cluster.openmetadata[*].identity[0].oidc[0].issuer)
}
