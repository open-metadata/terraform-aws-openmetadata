variable "airflow" {
  description = "Airflow configuration"
  type        = any
  default = {
    credentials = {
      username = "admin"
      password = {
        secret_ref = "airflow-auth"
        secret_key = "password"
      }
    }
    storage = {
      logs = 5
      dags = 5
    }
    pvc = {
      logs = "airflow-logs"
      dags = "airflow-dags"
    }
    subpath = {
      logs = "airflow-logs"
      dags = "airflow-dags"
    }
    db = {
      provisioner  = "aws"
      storage_size = 20
      port         = 5432
      db_name      = "airflow"
      aws = {
        identifier              = "airflow"
        instance_class          = "db.t4g.micro"
        maintenance_window      = "Sat:02:00-Sat:03:00"
        backup_window           = "03:00-04:00"
        backup_retention_period = 30
        multi_az                = true
        skip_final_snapshot     = false
        deletion_protection     = true
      }
      credentials = {
        username = "dbadmin"
        password = {
          secret_ref = "airflow-db-secrets"
          secret_key = "password"
        }
      }
      engine = {
        name    = "postgres"
        version = "16"
      }
    }
  }
}

variable "app_env_from" {
  type        = list(string)
  description = "List of Kubernetes secrets. Will be converted to environment variables for the OpenMetadata application."
  default     = []
}

variable "app_extra_envs" {
  type        = map(string)
  description = "Extra environment variables for the OpenMetadata application."
  default     = {}
}

variable "app_version" {
  type        = string
  description = "OpenMetadata version to deploy"
  default     = "1.5.12"
}

variable "azs_to_use" {
  description = "Availability zones to use in selected region"
  type        = number
  default     = 3
}

variable "db" {
  description = "OpenMetadata database configuration"
  type        = any
  default = {
    provisioner = "aws"
    aws = {
      identifier              = "openmetadata"
      instance_class          = "db.t4g.medium"
      maintenance_window      = "Sat:02:00-Sat:03:00"
      backup_window           = "03:00-04:00"
      backup_retention_period = 30
      multi_az                = true
      skip_final_snapshot     = false
      deletion_protection     = true
    }
    engine = {
      name    = "postgres"
      version = "16"
    }
    port         = 5432
    db_name      = "openmetadata_db"
    storage_size = 20
    credentials = {
      username = "dbadmin"
      password = {
        secret_ref = "db-secrets"
        secret_key = "password"
      }
    }
  }
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "open-metadata"
}

variable "opensearch" {
  description = "OpenSearch configuration"
  type        = any
  default = {
    provisioner = "aws"
    aws = {
      availability_zone_count = 2
      domain_name             = "openmetadata"
      engine_version          = "OpenSearch_2.7"
      instance_count          = 2
      instance_type           = "t3.small.search"
      tls_security_policy     = "Policy-Min-TLS-1-2-2019-07"
    }
    credentials = {
      username = "admin"
      password = {
        secret_ref = "opensearch-credentials"
        secret_key = "password"
      }
    }
    volume_size = 10
  }
}

variable "region" {
  description = "AWS region in which the resources will be deployed"
  type        = string
  default     = "eu-west-1"
}
