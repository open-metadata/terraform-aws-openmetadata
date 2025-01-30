variable "app_helm_chart_version" {
  type        = string
  description = "Version of the OpenMetadata Helm chart to deploy. If not specified, the variable `app_version` will be used."
  default     = null
}

variable "app_namespace" {
  type        = string
  default     = "openmetadata"
  description = "Namespace in which to deploy the OpenMetadata application."
}

variable "app_version" {
  type        = string
  description = "OpenMetadata version to deploy."
  default     = "1.6.2"
}

variable "docker_image_name" {
  type        = string
  default     = "docker.getcollate.io/openmetadata/server"
  description = "Full path of the server Docker image name, excluding the tag."
}

variable "docker_image_tag" {
  type        = string
  default     = null
  description = "Docker image tag for the server. If not specified, the variable `app_version` will be used."
}

variable "eks_nodes_sg_ids" {
  type        = list(string)
  description = "List of security group IDs attached to the EKS nodes. Allows traffic from the OpenMetadata application to the databases."
  default     = []
}

variable "env_from" {
  type        = list(string)
  description = "List of Kubernetes secrets. Will be converted to environment variables for the OpenMetadata application."
  default     = []
}

variable "extra_envs" {
  type        = map(string)
  description = "Extra environment variables for the OpenMetadata application."
  default     = {}
}

variable "initial_admins" {
  type        = string
  description = "List of initial admins to create in the OpenMetadata application, without the domain name."
  default     = "[admin]"
}

variable "kms_key_id" {
  type        = string
  description = "ARN of the KMS key to encrypt database and backups. If not specified, your account's default KMS key will be used."
  default     = null
}

variable "principal_domain" {
  type        = string
  description = "Domain name of the users. For example, `open-metadata.org`."
  default     = "open-metadata.org"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where the databases and OpenSearch will be deployed. The recommended configuration is to use private subnets."
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for deploying the databases and OpenSearch. For example, `vpc-xxxxxxxx`."
  default     = null
}

# OpenMetadata database configuration

variable "db" {
  description = "OpenMetadata's database configuration."
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
    host         = optional(string) # Database host address
    port         = optional(number) # Port on which the database is accessible
    provisioner  = string           # One of 'helm', 'aws', or 'existing'
    storage_size = optional(number) # Size of the database storage in GB
  })
  default = {
    provisioner = "helm"
  }
}

# AirFlow configuration

variable "airflow" {
  description = "Airflow configuration."
  type = object({
    credentials = optional(object({   # Airflow credentials
      password = optional(object({    # Password secret
        secret_key = optional(string) # Secret key for the Airflow password
        secret_ref = optional(string) # Secret reference for the Airflow password
      }))
      username = optional(string) # Username for Airflow
    }))
    db = optional(object({                         # Airflow's database configuration
      aws = optional(object({                      # AWS specific configuration for the Airflow database
        backup_retention_period = optional(number) # Number of days to retain database backups
        backup_window           = optional(string) # Preferred backup window for RDS
        deletion_protection     = optional(bool)   # The database can't be deleted when this value is set to true
        identifier              = optional(string) # Unique identifier for the AWS RDS instance
        instance_class          = optional(string) # Instance class of the AWS RDS instance
        maintenance_window      = optional(string) # Preferred maintenance window for RDS
        multi_az                = optional(bool)   # Whether to enable multi-AZ deployment
        skip_final_snapshot     = optional(bool)   # If true, no DBSnapshot is created when the database is deleted
      }))
      credentials = optional(object({   # Airflow database credentials
        password = optional(object({    # Password secret
          secret_key = optional(string) # Secret key for the Airflow database password
          secret_ref = optional(string) # Secret reference for the Airflow database password
        }))
        username = optional(string) # Username for the Airflow database
      }))
      db_name = optional(string)   # Name of the Airflow database
      engine = optional(object({   # Airflow database engine configuration
        name    = optional(string) # One of 'postgres' or 'mysql'
        version = optional(string) # Version of the database engine
      }))
      host         = optional(string) # Database host address for Airflow
      port         = optional(number) # Port on which the Airflow database is accessible
      provisioner  = string           # One of 'helm', 'aws', or 'existing'
      storage_size = optional(number) # Size of the Airflow database storage in GB
    }))
    endpoint    = optional(string)   # Endpoint URL for the Airflow instance
    provisioner = optional(string)   # One of 'helm' or 'existing'
    logs_cleanup = optional(object({ # Airflow logs cleanup configuration
      enabled     = optional(bool)   # Whether to enable log cleanup
      schedule    = optional(string) # Schedule for log cleanup
      retain_days = optional(number) # Number of days to retain logs
    }))
    storage = optional(object({ # Airflow storage configuration
      dags = optional(number)   # Size of storage allocated for DAGs (in GB)
      logs = optional(number)   # Size of storage allocated for logs (in GB)
    }))
  })
  default = {
    provisioner = "helm"
    db = {
      provisioner = "helm"
    }
  }
}

# OpenSearch configuration

variable "opensearch" {
  description = "Configuration for OpenSearch domain for OpenMetadata."
  type = object({
    aws = optional(object({                      # AWS specific configuration
      availability_zone_count = optional(number) # Number of availability zones to deploy the OpenSearch domain
      domain_name             = optional(string) # The OpenSearch domain name
      engine_version          = optional(string) # OpenSearch engine version
      instance_count          = optional(number) # Number of OpenSearch instances
      instance_type           = optional(string) # OpenSearch instance type
      tls_security_policy     = optional(string) # OpenSearch TLS security policy
    }))
    credentials = optional(object({
      password = optional(object({    # Password secret
        secret_ref = optional(string) # Secret reference for OpenSearch password
        secret_key = optional(string) # Secret key for OpenSearch password
      }))
      username = optional(string) # OpenSearch username
    }))
    host          = optional(string) # OpenSearch host
    port          = optional(string) # OpenSearch port, hardcoded to 443 if opensearch.provisioner is 'aws'
    provisioner   = optional(string) # One of 'helm', 'aws', or 'existing'
    scheme        = optional(string) # OpenSearch scheme, hardcoded to 'https' if opensearch.provisioner is 'aws'
    storage_class = optional(string) # OpenSearch storage class
    volume_size   = optional(number) # OpenSearch storage size in GB
  })
  default = {
    provisioner = "helm"
  }
}
