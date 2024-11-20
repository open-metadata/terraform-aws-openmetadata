## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
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
| <a name="input_app_namespace"></a> [app\_namespace](#input\_app\_namespace) | Namespace to deploy the OpenMetadata application. | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the EKS cluster where OpenMetadata will be deployed. | `string` | n/a | yes |
| <a name="input_eks_nodes_sg_ids"></a> [eks\_nodes\_sg\_ids](#input\_eks\_nodes\_sg\_ids) | List of security group IDs attached to the EKS nodes. Used to allow traffic from the OpenMetadata application to the databases. | `list(string)` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the KMS key to encrypt database and backups. Your account's default KMS key will be used if not specified. | `string` | `null` | no |
| <a name="input_opensearch"></a> [opensearch](#input\_opensearch) | Configuration for OpenSearch domain for OpenMetadata. | <pre>object({<br/>    aws = optional(object({                      # AWS specific configuration<br/>      availability_zone_count = optional(number) # Number of availability zones to deploy the OpenSearch domain<br/>      domain_name             = optional(string) # The OpenSearch domain name<br/>      engine_version          = optional(string) # OpenSearch engine version<br/>      instance_count          = optional(number) # Number of OpenSearch instances<br/>      instance_type           = optional(string) # OpenSearch instance type<br/>      tls_security_policy     = optional(string) # OpenSearch TLS security policy<br/>    }))<br/>    credentials = optional(object({<br/>      username = optional(string)     # OpenSearch username<br/>      password = optional(object({    # Password secret<br/>        secret_ref = optional(string) # Secret reference for OpenSearch password<br/>        secret_key = optional(string) # Secret key for OpenSearch password<br/>      }))<br/>    }))<br/>    host          = optional(string) # OpenSearch host<br/>    port          = optional(string) # OpenSearch port, hardcoded to 443 if opensearch.provisioner is 'aws'<br/>    provisioner   = optional(string) # One of 'helm', 'aws', or 'existing'<br/>    scheme        = optional(string) # OpenSearch scheme, hardcoded to 'https' if opensearch.provisioner is 'aws'<br/>    storage_class = optional(string) # OpenSearch storage class<br/>    volume_size   = optional(number) # OpenSearch storage size  <br/>  })</pre> | <pre>{<br/>  "provisioner": "helm"<br/>}</pre> | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnets IDs where the databases and OpenSearch will be deployed. The recommended configuration is to use private subnets. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy the databases and OpenSearch. For example: `vpc-xxxxxxxx`. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_opensearch_endpoint"></a> [opensearch\_endpoint](#output\_opensearch\_endpoint) | n/a |
| <a name="output_opensearch_port"></a> [opensearch\_port](#output\_opensearch\_port) | n/a |
| <a name="output_opensearch_scheme"></a> [opensearch\_scheme](#output\_opensearch\_scheme) | n/a |