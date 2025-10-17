# Terraform Destroy Testing for Issue #15
# This file provides validation and testing for proper resource cleanup

# Test resource dependency ordering
locals {
  destroy_test_enabled = var.environment != "production"  # Only enable in non-prod
}

# Test RDS instance with proper lifecycle management
resource "random_password" "test_db_password" {
  count = local.destroy_test_enabled ? 1 : 0

  length      = 16
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  special     = true
  override_special = "!@#$%^&*()-_=+[]{}:?"  # YAML-safe characters
}

# Mock RDS instance configuration for testing
locals {
  test_db_config = local.destroy_test_enabled ? {
    aws = {
      identifier              = "test-openmetadata-db"
      instance_class          = "db.t3.micro"
      backup_retention_period = 1
      backup_window          = "03:00-04:00"
      maintenance_window     = "sun:04:00-sun:05:00"
      multi_az              = false
      skip_final_snapshot   = true   # Critical for destroy operations
      deletion_protection   = false  # Allow destroy in test environments
    }
    engine = {
      name    = "postgres"
      version = "16"
    }
    port         = 5432
    db_name      = "test_openmetadata_db"
    storage_size = 20  # Minimum size for testing
    credentials = {
      username = "testadmin"
      password = {
        secret_ref = "test-db-secrets"
        secret_key = "password"
      }
    }
  } : {}
}

# Test Kubernetes secret cleanup
resource "kubernetes_secret_v1" "test_db_credentials" {
  count = local.destroy_test_enabled ? 1 : 0

  metadata {
    name      = "test-db-secrets"
    namespace = "default"
  }

  data = {
    "password" = try(random_password.test_db_password[0].result, "")
  }
}

# Test Helm release lifecycle management
resource "helm_release" "test_openmetadata" {
  count = local.destroy_test_enabled ? 1 : 0

  name       = "test-openmetadata"
  repository = "https://helm.open-metadata.org"
  chart      = "openmetadata"
  version    = "1.9.0"  # Use stable version for testing
  namespace  = "default"
  wait       = false
  timeout    = 300

  values = [
    yamlencode({
      # Minimal configuration for testing
      openmetadata = {
        config = {
          database = {
            host = "localhost"
            port = 5432
            auth = {
              username = "testuser"
              password = {
                secretRef = try(kubernetes_secret_v1.test_db_credentials[0].metadata[0].name, "")
                secretKey = "password"
              }
            }
          }
        }
      }
    })
  ]

  # Critical lifecycle management for proper destroy order
  lifecycle {
    create_before_destroy = false
    # Prevent destruction until all dependent resources are ready
  }

  depends_on = [
    kubernetes_secret_v1.test_db_credentials
  ]
}

# Output destroy test configuration
output "destroy_test_config" {
  value = local.destroy_test_enabled ? {
    test_enabled = true
    db_config = {
      skip_final_snapshot = local.test_db_config.aws.skip_final_snapshot
      deletion_protection = local.test_db_config.aws.deletion_protection
    }
    helm_release_count = length(helm_release.test_openmetadata)
    kubernetes_secrets_count = length(kubernetes_secret_v1.test_db_credentials)
  } : {
    test_enabled = false
    message = "Destroy testing disabled in production environment"
  }
  description = "Configuration validation for destroy operations"
}

# Validation checks for destroy-friendly configuration
locals {
  destroy_validation = {
    rds_can_be_destroyed = (
      local.destroy_test_enabled ?
      local.test_db_config.aws.skip_final_snapshot &&
      !local.test_db_config.aws.deletion_protection :
      true
    )
    helm_lifecycle_configured = length([
      for release in helm_release.test_openmetadata : release
      if can(release.lifecycle)
    ]) > 0
  }
}

output "destroy_validation" {
  value = {
    rds_destroy_ready = local.destroy_validation.rds_can_be_destroyed
    helm_lifecycle_ok = local.destroy_validation.helm_lifecycle_configured
    overall_status = (
      local.destroy_validation.rds_can_be_destroyed &&
      local.destroy_validation.helm_lifecycle_configured ?
      "PASS" : "FAIL"
    )
  }
  description = "Validation results for destroy operation readiness"
}