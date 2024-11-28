locals {
  opensearch_provisioner         = coalesce(try(var.opensearch.provisioner, null), local.opensearch_default_provisioner)
  opensearch_credentials_enabled = try(var.opensearch.credentials, null) != null ? true : false

  opensearch_aws_config = local.opensearch_provisioner == "aws" ? {
    aws = {
      availability_zone_count = coalesce(try(var.opensearch.aws.availability_zone_count, null), local.opensearch_aws_defaults.aws.availability_zone_count)
      domain_name             = coalesce(try(var.opensearch.aws.domain_name, null), local.opensearch_aws_defaults.aws.domain_name)
      engine_version          = coalesce(try(var.opensearch.aws.engine_version, null), local.opensearch_aws_defaults.aws.engine_version)
      instance_count          = coalesce(try(var.opensearch.aws.instance_count, null), local.opensearch_aws_defaults.aws.instance_count)
      instance_type           = coalesce(try(var.opensearch.aws.instance_type, null), local.opensearch_aws_defaults.aws.instance_type)
      tls_security_policy     = coalesce(try(var.opensearch.aws.tls_security_policy, null), local.opensearch_aws_defaults.aws.tls_security_policy)
    }
    credentials = {
      username = coalesce(try(var.opensearch.credentials.username, null), local.opensearch_aws_defaults.credentials.username)
      password = {
        secret_ref = coalesce(try(var.opensearch.credentials.password.secret_ref, null), local.opensearch_aws_defaults.credentials.password.secret_ref)
        secret_key = coalesce(try(var.opensearch.credentials.password.secret_key, null), local.opensearch_aws_defaults.credentials.password.secret_key)
      }
    }
    port        = coalesce(try(var.opensearch.port, null), local.opensearch_aws_defaults.port)
    scheme      = coalesce(try(var.opensearch.scheme, null), local.opensearch_aws_defaults.scheme)
    volume_size = coalesce(try(var.opensearch.volume_size, null), local.opensearch_aws_defaults.volume_size)
  } : null

  opensearch_helm_config = local.opensearch_provisioner == "helm" ? {
    volume_size = coalesce(try(var.opensearch.volume_size, null), local.opensearch_helm_defaults.volume_size)
  } : null

  opensearch_existing_config = local.opensearch_provisioner == "existing" ? var.opensearch : null

  opensearch_config = {
    helm     = local.opensearch_helm_config
    aws      = local.opensearch_aws_config
    existing = local.opensearch_existing_config
  }

  opensearch = local.opensearch_config[local.opensearch_provisioner]

}
