data "aws_iam_policy_document" "opensearch" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["es:ESHttp*"]
    resources = ["*"]
  }
}

resource "aws_opensearch_domain" "opensearch" {
  domain_name    = var.opensearch.aws.domain_name
  engine_version = var.opensearch.aws.engine_version

  cluster_config {
    instance_type            = var.opensearch.aws.instance_type
    dedicated_master_enabled = false
    instance_count           = var.opensearch.aws.instance_count
    zone_awareness_enabled   = true
    zone_awareness_config {
      availability_zone_count = var.opensearch.aws.availability_zone_count
    }
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.opensearch.credentials.username
      master_user_password = local.opensearch_password
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.opensearch.volume_size
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_id
  }

  node_to_node_encryption {
    enabled = true
  }

  vpc_options {
    subnet_ids         = slice(var.subnet_ids, 0, 2)
    security_group_ids = [module.opensearch_sg.security_group_id]
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = var.opensearch.aws.tls_security_policy
  }

  access_policies = data.aws_iam_policy_document.opensearch.json
}

module "opensearch_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>5.2"

  name               = "${var.opensearch.aws.domain_name}-opensearch"
  description        = "Security group for OpenMetadata opensearch"
  vpc_id             = var.vpc_id
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  ingress_with_source_security_group_id = [for sg_id in var.eks_nodes_sg_ids :
    {
      from_port                = "443"
      to_port                  = "443"
      protocol                 = "tcp"
      description              = "OpenSearch from ${sg_id}"
      source_security_group_id = sg_id
    }
  ]
}

# Search engine credentials

# AWS OpenSearch requires at least one special character in the master password.
# However, passwords that start with a special character break YAML parsing when
# the OpenMetadata app embeds the secret value inline in openmetadata.yaml.
# To satisfy both constraints, the password is built in two parts:
#   1. A guaranteed uppercase letter prefix (always YAML-safe as first character)
#   2. The rest of the password with specials limited to _ - . (also YAML-safe mid-value)
# The two parts are joined in the local below.

resource "random_string" "opensearch_password_prefix" {
  length  = 1
  upper   = true
  lower   = false
  numeric = false
  special = false
}

resource "random_password" "opensearch_password" {
  length           = 23
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  special          = true
  override_special = "_-."
}

locals {
  opensearch_password = "${random_string.opensearch_password_prefix.result}${random_password.opensearch_password.result}"
}

resource "kubernetes_secret_v1" "opensearch_credentials" {
  metadata {
    name      = var.opensearch.credentials.password.secret_ref
    namespace = var.namespace
  }

  data = {
    (var.opensearch.credentials.password.secret_key) = local.opensearch_password
  }
}

