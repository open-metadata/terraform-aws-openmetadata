# EFS CSI driver EKS addon & IAM role for the EFS CSI driver's service account
# https://docs.open-metadata.org/latest/deployment/kubernetes/eks#persistent-volumes-with-readwritemany-access-modes

resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name             = local.eks_cluster_name
  addon_name               = "aws-efs-csi-driver"
  service_account_role_arn = module.efs_csi_irsa.iam_role_arn
  depends_on = [
    module.efs_csi_irsa,
    aws_eks_node_group.nodes
  ]
}

module "efs_csi_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "efs-csi"
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa", "kube-system:efs-csi-node-sa"]
    }
  }
}
