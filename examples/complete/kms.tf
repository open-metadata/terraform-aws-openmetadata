# KMS key and alias

locals {
  kms_key_alias = "alias/openmetadata"
  kms_key_id    = aws_kms_alias.this.target_key_arn
}

resource "aws_kms_key" "this" {
  description             = "An example symmetric encryption KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "this" {
  name          = local.kms_key_alias
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "default"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}
