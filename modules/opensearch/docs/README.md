## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_opensearch_sg"></a> [opensearch\_sg](#module\_opensearch\_sg) | terraform-aws-modules/security-group/aws | ~>5.2 |

## Resources

| Name | Type |
|------|------|
| [aws_opensearch_domain.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain) | resource |
| [kubernetes_secret_v1.opensearch_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [random_password.opensearch_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_iam_policy_document.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_nodes_sg_ids"></a> [eks\_nodes\_sg\_ids](#input\_eks\_nodes\_sg\_ids) | List of security group IDs attached to the EKS nodes. Used to allow traffic from the OpenMetadata application to the databases. | `list(string)` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the KMS key to encrypt database and backups. Your account's default KMS key will be used if not specified. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to deploy the Kubernetes secret. Must be the OpenMetadata application's namespace. | `string` | n/a | yes |
| <a name="input_opensearch"></a> [opensearch](#input\_opensearch) | Configuration for OpenSearch domain for OpenMetadata. | <pre>object({<br/>    aws = optional(object({                      # AWS specific configuration<br/>      availability_zone_count = optional(number) # Number of availability zones to deploy the OpenSearch domain<br/>      domain_name             = optional(string) # The OpenSearch domain name<br/>      engine_version          = optional(string) # OpenSearch engine version<br/>      instance_count          = optional(number) # Number of OpenSearch instances<br/>      instance_type           = optional(string) # OpenSearch instance type<br/>      tls_security_policy     = optional(string) # OpenSearch TLS security policy<br/>    }))<br/>    credentials = optional(object({<br/>      username = optional(string)     # OpenSearch username<br/>      password = optional(object({    # Password secret<br/>        secret_ref = optional(string) # Secret reference for OpenSearch password<br/>        secret_key = optional(string) # Secret key for OpenSearch password<br/>      }))<br/>    }))<br/>    volume_size = optional(number) # OpenSearch storage size in GB<br/>  })</pre> | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnets IDs where the databases and OpenSearch will be deployed. The recommended configuration is to use private subnets. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy the databases and OpenSearch. For example: `vpc-xxxxxxxx`. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The endpoint of the OpenSearch domain |
| <a name="output_port"></a> [port](#output\_port) | The port of the OpenSearch domain. Hardcoded to 443 |
| <a name="output_scheme"></a> [scheme](#output\_scheme) | The scheme of the OpenSearch domain. Hardcoded to https |