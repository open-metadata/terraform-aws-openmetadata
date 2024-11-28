variable "eks_nodes_sg_ids" {
  type        = list(string)
  description = "List of security group IDs attached to the EKS nodes. Used to allow traffic from the OpenMetadata application to the databases."
}

variable "kms_key_id" {
  type        = string
  description = "The ARN of the KMS key to encrypt database and backups. Your account's default KMS key will be used if not specified."
  default     = null
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy the Kubernetes secrets."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets IDs where the databases and OpenSearch will be deployed. The recommended configuration is to use private subnets."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy the databases and OpenSearch. For example: `vpc-xxxxxxxx`."
}

variable "db_config" {
  description = "Database configuration."
  type = object({
    aws = optional(object({                      # AWS specific configuration for the database
      backup_retention_period = optional(number) # Number of days to retain database backups
      backup_window           = optional(string) # Preferred backup window for RDS
      deletion_protection     = optional(bool)   # The database can't be deleted when this value is set to true
      identifier              = optional(string) # Unique identifier for the AWS RDS instance
      instance_class          = optional(string) # Instance class of the AWS RDS instance
      maintenance_window      = optional(string) # Preferred maintenance window for RDS
      multi_az                = optional(bool)   # Whether to enable multi-AZ deployment
      skip_final_snapshot     = optional(bool)   # If true, no DBSnapshot is created when the database is deleted
    }))
    credentials = optional(object({   # Database credentials
      password = optional(object({    # Password secret
        secret_key = optional(string) # Secret key for the database password
        secret_ref = optional(string) # Secret reference for the database password
      }))
      username = optional(string) # Username for the database
    }))
    db_name = optional(string)   # Name of the database
    engine = optional(object({   # Database engine configuration
      name    = optional(string) # One of 'postgres' or 'mysql'
      version = optional(string) # Version of the database engine
    }))
    port         = optional(number) # Port on which the database is accessible
    storage_size = optional(number) # Size of the database storage in GB
  })
}
