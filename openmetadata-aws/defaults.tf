# This file contains the default values for each component, depending on the provisioner used.

locals {
  opensearch_default_provisioner = "helm"
  db_default_provisioner         = "helm"
  airflow_default_provisioner    = "helm"
  airflow_db_default_provisioner = "helm"

  omd_defaults = {
    namespace          = var.app_namespace
    app_version        = var.app_version
    docker_image_name  = var.docker_image_name
    docker_image_tag   = var.docker_image_tag != null ? var.docker_image_tag : var.app_version
    helm_chart_version = var.app_helm_chart_version != null ? var.app_helm_chart_version : var.app_version
    docker_image_name  = var.docker_image_name
    initial_admins     = var.initial_admins
    principal_domain   = var.principal_domain
    image_pull_policy  = "IfNotPresent"
    env_from           = var.app_env_from
    extra_envs         = var.app_extra_envs
  }

  opensearch_aws_defaults = {
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
    port        = "443"
    scheme      = "https"
    volume_size = 10
  }

  opensearch_helm_defaults = {
    volume_size = 15
  }

  opensearch_existing_defaults = {
    port   = "443"
    scheme = "https"
  }

  db_aws_defaults = {
    aws = {
      identifier              = "openmetadata"
      instance_class          = "db.t4g.medium"
      multi_az                = true
      maintenance_window      = "Sat:02:00-Sat:03:00"
      backup_window           = "03:00-04:00"
      backup_retention_period = 30
    }
    engine = {
      name    = "postgres" # harcoded later, set here jfyi
      version = "16"
    }
    port         = 5432
    db_name      = "openmetadata_db"
    storage_size = 50
    credentials = {
      username = "dbadmin"
      password = {
        secret_ref = "db-secrets"
        secret_key = "password"
      }
    }
  }

  # When deploying databases with helm, OpenMetadata and Airflow databases are deployed in the same MySQL server.
  shared_db_helm_defaults = {
    engine = {
      name = "mysql"
    }
    port         = "3306"
    storage_size = 50
  }

  db_existing_defaults = {
    port = "5432"
  }

  airflow_db_aws_defaults = {
    aws = {
      identifier              = "airflow"
      instance_class          = "db.t4g.micro"
      multi_az                = true
      maintenance_window      = "Sat:02:00-Sat:03:00"
      backup_window           = "03:00-04:00"
      backup_retention_period = 30
    }
    engine = {
      name    = "postgres" # harcoded later, set here jfyi
      version = "16"
    }
    port         = "5432"
    db_name      = "airflow"
    storage_size = 10
    credentials = {
      username = "dbadmin"
      password = {
        secret_ref = "airflow-db-secrets"
        secret_key = "password"
      }
    }
  }
  airflow_db_existing_defaults = {
    port = "5432"
  }


  airflow_helm_defaults = {
    endpoint = "http://openmetadata-deps-web.${var.app_namespace}.svc:8080"
    credentials = {
      username = "admin"
      password = {
        secret_ref = "airflow-auth"
        secret_key = "password"
      }
    }
    storage = {
      logs = 10
      dags = 10
    }
    pvc = {
      logs = "airflow-logs"
      dags = "airflow-dags"
    }
    subpath = {
      logs = "airflow-logs"
      dags = "airflow-dags"
    }
  }

  airflow_existing_defaults = {
    port = "8080"
  }
}
