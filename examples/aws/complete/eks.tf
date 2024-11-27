locals {
  eks_cluster_name              = var.eks_cluster_name
  eks_version                   = "1.31"
  eks_cidr                      = "10.100.0.0/24"
  eks_node_group_instance_types = ["t3.xlarge"]
  eks_nodes_disk_size           = 20
  eks_nodes_sg_id               = aws_eks_cluster.openmetadata.vpc_config[0].cluster_security_group_id
}

# EKS cluster

resource "aws_eks_cluster" "openmetadata" {
  name                          = local.eks_cluster_name
  role_arn                      = aws_iam_role.eks_cluster.arn
  bootstrap_self_managed_addons = true
  version                       = local.eks_version
  enabled_cluster_log_types     = []
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = local.eks_cidr
  }
  upgrade_policy {
    support_type = "STANDARD"
  }
  vpc_config {
    subnet_ids              = local.subnet_ids
    endpoint_private_access = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }
}

# EKS OIDC provider

resource "aws_iam_openid_connect_provider" "this" {
  url             = aws_eks_cluster.openmetadata.identity[0].oidc[0].issuer
  thumbprint_list = [one(data.tls_certificate.cluster[*].certificates[0].sha1_fingerprint)]
  client_id_list  = ["sts.amazonaws.com"]
}

# EKS node group

resource "aws_eks_node_group" "nodes" {
  cluster_name    = local.eks_cluster_name
  node_group_name = "eks-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = local.subnet_ids
  disk_size       = local.eks_nodes_disk_size
  instance_types  = local.eks_node_group_instance_types
  ami_type        = "AL2_x86_64"
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [aws_eks_cluster.openmetadata]
}
