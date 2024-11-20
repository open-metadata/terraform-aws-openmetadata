## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_efs_file_system.airflow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.airflow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_security_group.airflow_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [kubernetes_job_v1.efs_provision](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job_v1) | resource |
| [kubernetes_persistent_volume_claim_v1.airflow](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim_v1) | resource |
| [kubernetes_persistent_volume_v1.airflow](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_v1) | resource |
| [kubernetes_storage_class_v1.airflow_efs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_airflow"></a> [airflow](#input\_airflow) | Airflow configuration. | <pre>object({<br/>    #    credentials = optional(object({   # Airflow credentials<br/>    #      password = optional(object({    # Password secret<br/>    #        secret_key = optional(string) # Secret key for the Airflow password<br/>    #        secret_ref = optional(string) # Secret reference for the Airflow password<br/>    #      }))<br/>    #      username = optional(string) # Username for Airflow<br/>    #    }))<br/>    #    db = optional(object({                         # Airflow's database configuration<br/>    #      aws = optional(object({                      # AWS specific configuration for the Airflow database<br/>    #        backup_retention_period = optional(number) # Number of days to retain database backups<br/>    #        backup_window           = optional(string) # Preferred backup window for RDS<br/>    #        identifier              = optional(string) # Unique identifier for the AWS RDS instance<br/>    #        instance_class          = optional(string) # Instance class of the AWS RDS instance<br/>    #        maintenance_window      = optional(string) # Preferred maintenance window for RDS<br/>    #        multi_az                = optional(bool)   # Whether to enable multi-AZ deployment<br/>    #      }))<br/>    #      credentials = optional(object({   # Airflow database credentials<br/>    #        password = optional(object({    # Password secret<br/>    #          secret_key = optional(string) # Secret key for the Airflow database password<br/>    #          secret_ref = optional(string) # Secret reference for the Airflow database password<br/>    #        }))<br/>    #        username = optional(string) # Username for the Airflow database<br/>    #      }))<br/>    #      db_name = optional(string)   # Name of the Airflow database<br/>    #      engine = optional(object({   # Airflow database engine configuration<br/>    #        name    = optional(string) # One of 'postgres' or 'mysql'<br/>    #        version = optional(string) # Version of the database engine<br/>    #      }))<br/>    #      host         = optional(string) # Database host address for Airflow<br/>    #      port         = optional(number) # Port on which the Airflow database is accessible<br/>    #      provisioner  = string           # One of 'helm', 'aws', or 'existing'<br/>    #      storage_size = optional(number) # Size of the Airflow database storage in GB<br/>    #    }))<br/>    #    endpoint    = optional(string) # Endpoint URL for the Airflow instance<br/>    #    provisioner = optional(string) # One of 'helm' or 'existing'<br/>    pvc = object({<br/>      dags = string<br/>      logs = string<br/>    })<br/>    storage = object({<br/>      dags = number<br/>      logs = number<br/>    })<br/>    subpath = object({<br/>      dags = string<br/>      logs = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the EKS cluster where OpenMetadata will be deployed. | `string` | n/a | yes |
| <a name="input_eks_nodes_sg_ids"></a> [eks\_nodes\_sg\_ids](#input\_eks\_nodes\_sg\_ids) | List of security group IDs attached to the EKS nodes. Used to allow traffic from the OpenMetadata application to the databases. | `list(string)` | n/a | yes |
| <a name="input_enable_helpers"></a> [enable\_helpers](#input\_enable\_helpers) | Enable the Kubernetes job that will crete the initial folders on the EFS instances. | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the KMS key to encrypt database and backups. Your account's default KMS key will be used if not specified. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to deploy the resources. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnets IDs where the databases and OpenSearch will be deployed. The recommended configuration is to use private subnets. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy the databases and OpenSearch. For example: `vpc-xxxxxxxx`. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pvcs"></a> [pvcs](#output\_pvcs) | n/a |