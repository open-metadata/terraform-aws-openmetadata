# IAM roles for EKS cluster and nodes

locals {
  eks_nodes_managed_policies = [
    "AmazonEC2ContainerRegistryReadOnly",
    "AmazonEKS_CNI_Policy",
    "AmazonEKSWorkerNodePolicy"
  ]
}

# IAM role for EKS cluster

data "aws_iam_policy_document" "eks_cluster" {
  statement {
    sid       = "AdminEKS"
    actions   = ["eks:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowAssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "eks_cluster" {
  name   = "eks-cluster"
  role   = aws_iam_role.eks_cluster.id
  policy = data.aws_iam_policy_document.eks_cluster.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM role for EKS nodes

data "aws_iam_policy_document" "eks_nodes_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    sid     = "AllowAssumeRole"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_nodes" {
  name               = "eks-nodes"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.eks_nodes_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_nodes" {
  for_each = toset(local.eks_nodes_managed_policies)

  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
}
