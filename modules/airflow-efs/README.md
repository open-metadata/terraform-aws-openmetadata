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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sg_efs"></a> [sg\_efs](#module\_sg\_efs) | terraform-aws-modules/security-group/aws | ~>5.2 |

## Resources

| Name | Type |
|------|------|
| [aws_efs_file_system.airflow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.airflow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [kubernetes_job_v1.efs_provision](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job_v1) | resource |
| [kubernetes_persistent_volume_claim_v1.airflow](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim_v1) | resource |
| [kubernetes_persistent_volume_v1.airflow](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_v1) | resource |
| [kubernetes_storage_class_v1.airflow_efs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_airflow"></a> [airflow](#input\_airflow) | Airflow configuration. | <pre>object({<br/>    pvc = object({<br/>      dags = string<br/>      logs = string<br/>    })<br/>    storage = object({<br/>      dags = number<br/>      logs = number<br/>    })<br/>    subpath = object({<br/>      dags = string<br/>      logs = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_eks_nodes_sg_ids"></a> [eks\_nodes\_sg\_ids](#input\_eks\_nodes\_sg\_ids) | List of security group IDs attached to the EKS nodes. Allows traffic from them to the EFS instances. | `list(string)` | n/a | yes |
| <a name="input_enable_helpers"></a> [enable\_helpers](#input\_enable\_helpers) | Enable the Kubernetes job that will crete the initial folders on the EFS instances. | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the KMS key to encrypt database and backups. Your account's default KMS key will be used if not specified. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to deploy the resources. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnets IDs where the databases and OpenSearch will be deployed. The recommended configuration is to use private subnets. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy the databases and OpenSearch. For example: `vpc-xxxxxxxx`. | `string` | n/a | yes |

## Outputs

No outputs.