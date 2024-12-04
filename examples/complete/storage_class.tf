# Encrypted storage class

resource "kubernetes_storage_class" "encrypted_gp3" {
  metadata {
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
    name = "encrypted-gp3"
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    kmsKeyId  = aws_kms_alias.this.target_key_arn
    encrypted = "true"
    type      = "gp3"
    fsType    = "ext4"
  }
}
