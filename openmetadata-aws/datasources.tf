data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}
