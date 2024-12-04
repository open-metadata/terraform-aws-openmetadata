## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds/aws | ~>6.10 |
| <a name="module_sg_db"></a> [sg\_db](#module\_sg\_db) | terraform-aws-modules/security-group/aws | ~>5.2 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_secret_v1.db_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_config"></a> [db\_config](#input\_db\_config) | Database configuration. | <pre>object({<br/>    aws = optional(object({                      # AWS specific configuration for the database<br/>      backup_retention_period = optional(number) # Number of days to retain database backups<br/>      backup_window           = optional(string) # Preferred backup window for RDS<br/>      deletion_protection     = optional(bool)   # The database can't be deleted when this value is set to true<br/>      identifier              = optional(string) # Unique identifier for the AWS RDS instance<br/>      instance_class          = optional(string) # Instance class of the AWS RDS instance<br/>      maintenance_window      = optional(string) # Preferred maintenance window for RDS<br/>      multi_az                = optional(bool)   # Whether to enable multi-AZ deployment<br/>      skip_final_snapshot     = optional(bool)   # If true, no DBSnapshot is created when the database is deleted<br/>    }))<br/>    credentials = optional(object({   # Database credentials<br/>      password = optional(object({    # Password secret<br/>        secret_key = optional(string) # Secret key for the database password<br/>        secret_ref = optional(string) # Secret reference for the database password<br/>      }))<br/>      username = optional(string) # Username for the database<br/>    }))<br/>    db_name = optional(string)   # Name of the database<br/>    engine = optional(object({   # Database engine configuration<br/>      name    = optional(string) # One of 'postgres' or 'mysql'<br/>      version = optional(string) # Version of the database engine<br/>    }))<br/>    port         = optional(number) # Port on which the database is accessible<br/>    storage_size = optional(number) # Size of the database storage in GB<br/>  })</pre> | n/a | yes |
| <a name="input_eks_nodes_sg_ids"></a> [eks\_nodes\_sg\_ids](#input\_eks\_nodes\_sg\_ids) | List of security group IDs attached to the EKS nodes. Used to allow traffic from the OpenMetadata application to the databases. | `list(string)` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the KMS key to encrypt database and backups. Your account's default KMS key will be used if not specified. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to deploy the Kubernetes secrets. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnets IDs where the databases and OpenSearch will be deployed. The recommended configuration is to use private subnets. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy the databases and OpenSearch. For example: `vpc-xxxxxxxx`. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_instance_address"></a> [db\_instance\_address](#output\_db\_instance\_address) | The address of the RDS instance |
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | The ARN of the RDS instance |
| <a name="output_db_instance_identifier"></a> [db\_instance\_identifier](#output\_db\_instance\_identifier) | The identifier of the RDS instance |
| <a name="output_db_instance_name"></a> [db\_instance\_name](#output\_db\_instance\_name) | The database name |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | The database port |