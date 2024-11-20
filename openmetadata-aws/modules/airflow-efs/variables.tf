variable "airflow" {
  description = "Airflow configuration."
  type = object({
    #    credentials = optional(object({   # Airflow credentials
    #      password = optional(object({    # Password secret
    #        secret_key = optional(string) # Secret key for the Airflow password
    #        secret_ref = optional(string) # Secret reference for the Airflow password
    #      }))
    #      username = optional(string) # Username for Airflow
    #    }))
    #    db = optional(object({                         # Airflow's database configuration
    #      aws = optional(object({                      # AWS specific configuration for the Airflow database
    #        backup_retention_period = optional(number) # Number of days to retain database backups
    #        backup_window           = optional(string) # Preferred backup window for RDS
    #        identifier              = optional(string) # Unique identifier for the AWS RDS instance
    #        instance_class          = optional(string) # Instance class of the AWS RDS instance
    #        maintenance_window      = optional(string) # Preferred maintenance window for RDS
    #        multi_az                = optional(bool)   # Whether to enable multi-AZ deployment
    #      }))
    #      credentials = optional(object({   # Airflow database credentials
    #        password = optional(object({    # Password secret
    #          secret_key = optional(string) # Secret key for the Airflow database password
    #          secret_ref = optional(string) # Secret reference for the Airflow database password
    #        }))
    #        username = optional(string) # Username for the Airflow database
    #      }))
    #      db_name = optional(string)   # Name of the Airflow database
    #      engine = optional(object({   # Airflow database engine configuration
    #        name    = optional(string) # One of 'postgres' or 'mysql'
    #        version = optional(string) # Version of the database engine
    #      }))
    #      host         = optional(string) # Database host address for Airflow
    #      port         = optional(number) # Port on which the Airflow database is accessible
    #      provisioner  = string           # One of 'helm', 'aws', or 'existing'
    #      storage_size = optional(number) # Size of the Airflow database storage in GB
    #    }))
    #    endpoint    = optional(string) # Endpoint URL for the Airflow instance
    #    provisioner = optional(string) # One of 'helm' or 'existing'
    pvc = object({
      dags = string
      logs = string
    })
    storage = object({
      dags = number
      logs = number
    })
    subpath = object({
      dags = string
      logs = string
    })
  })
}


variable "namespace" {
  type        = string
  description = "Namespace to deploy the resources."
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster where OpenMetadata will be deployed."
}

variable "eks_nodes_sg_ids" {
  type        = list(string)
  description = "List of security group IDs attached to the EKS nodes. Used to allow traffic from the OpenMetadata application to the databases."
}

variable "enable_helpers" {
  type        = bool
  description = "Enable the Kubernetes job that will crete the initial folders on the EFS instances."
  default     = true
}

variable "kms_key_id" {
  type        = string
  description = "The ARN of the KMS key to encrypt database and backups. Your account's default KMS key will be used if not specified."
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets IDs where the databases and OpenSearch will be deployed. The recommended configuration is to use private subnets."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy the databases and OpenSearch. For example: `vpc-xxxxxxxx`."
}
