provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "provisioner" = "terraform"
      "project"     = "openmetadata"
    }
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.openmetadata.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.openmetadata.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name, "--region", var.region]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.openmetadata.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.openmetadata.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name, "--region", var.region]
      command     = "aws"
    }
  }
}
