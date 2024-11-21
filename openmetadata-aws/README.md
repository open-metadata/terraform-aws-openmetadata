# OpenMetadata Terraform module for AWS

# Provisioners

This module enables you to choose from multiple provisioners to deploy the components and dependencies of OpenMetadata on AWS. The available provisioners for each component are:

|                             | Helm  |  AWS  | Existing | Default provisioner|
| :-------------------------- | :---: | :---: |  :---:  | :-----------------: |
| **OpenMetadata**            |  ✅   |  🟥   |    🟥   |      Helm           |
| **OpenMetadata database**   |  ✅   |  ✅   |    ✅   |      Helm           |
| **Airflow**                 |  ✅   |  🟥   |    ✅   |      Helm           |
| **Airflow database**        |  ✅   |  ✅   |    ✅   |      Helm           |
| **OpenSearch**              |  ✅   |  ✅   |    ✅   |      Helm           |

> [!NOTE]
> If you select `existing` as the provisioner for Airflow, we expect the service to be fully functional, including its database.
> The Airflow database will not be deployed in this scenario.

# How we manage settings

Components have default values for each provisioner, which are defined in the `defaults.tf` file.
The final settings for each component are determined by checking whether a value has been provided for each parameter. If a value is not provided for a parameter, the default one is used. This process is handled in the `component_conf.tf` files.

# Usage

The following examples show how to use the module with different provisioners. Even though each example use the same provisioner for all components, you can use different provisioners for any component if you prefer.

## Helm

Using `helm` as provisioner for all components:

```hcl
module "omd" {
  source = "github.com/open-metadata/openmetadata-terraform//openmetadata-aws?ref=[version]"

  # Namespace where OpenMetadata and dependencies will be deployed
  app_namespace    = "example"

  # Version of OpenMetadata to deploy
  app_version      = "1.6"

  # ARN of the KMS key used to encrypt the EFS instances
  kms_key_id       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  # Subnet IDs, used for the Airflow's EFS mount targets and EFS security group
  subnet_ids       = ["subnet-1a2b3c4d", "subnet-5e6f7g8h", "subnet-9i0j1k2l"]

  # VPC ID for the security groups of the EFS instances
  vpc_id = "vpc-1a2b3c4d"

}
```

## AWS

Using `aws` as provisioner for all possible components:

```hcl
module "omd" {
  source = "github.com/open-metadata/openmetadata-terraform//openmetadata-aws?ref=[version]"
  
  # Namespace where OpenMetadata and dependencies will be deployed
  app_namespace = "example"

  # Version of OpenMetadata to deploy
  app_version  = "1.6"

  # Security group IDs assigned to the EKS nodes, the security groups of the RDS instances and OpenSearch domain will allow inbound traffic from them
  eks_nodes_sg_ids = ["sg-1234abcd5678efgh", "sg-8765ijkl4321mnop"]

  # ARN of the KMS key used to encrypt resources 
  kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  # Subnet IDs, used for:
  # the Airflow's EFS mount targets and EFS security group
  # the subnet group for the RDS instances
  # the OpenSearch domain
  subnet_ids = ["subnet-1a2b3c4d", "subnet-5e6f7g8h", "subnet-9i0j1k2l"]

  # VPC ID for the security groups of the EFS instances, the RDS instances, and the OpenSearch domain
  vpc_id = "vpc-1a2b3c4d"

  # OpenMetadata database settings
  db = {
    provisioner = "aws"
  }

  # Airflow settings
  airflow = {
    db = {
      provisioner = "aws"
    }
  }

  # OpenSearch settings
  opensearch = {
    provisioner = "aws"
  }
}
```

## Existing

Using `existing` as provisioner for all possible components:

```hcl
module "omd" {
  source = "github.com/open-metadata/openmetadata-terraform//openmetadata-aws?ref=[version]"

  # Namespace where OpenMetadata and dependencies will be deployed
  app_namespace = "example"

  # Version of OpenMetadata to deploy
  app_version  = "1.6"

  # ARN of the KMS key used to encrypt resources
  kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  # OpenMetadata database settings
  db = {
    provisioner = "existing"
    host        = "omd-db.postgres.example"
    port        = "5432"
    db_name     = "openmetadata_db"
    engine = {
      name = "postgres"
    }
    credentials = {
      username = "dbadmin"
      password = {
        secret_ref = "db-secrets"
        secret_key = "password"
      }
    }
  }

  # Airflow settings
  airflow = {
    provisioner = "existing"
    endpoint = "http://airflow.example:8080"
    credentials = {
      username = "admin"
      password = {
        secret_ref = "airflow-auth"
        secret_key = "password"
      }
    }
  }

  # OpenSearch settings
  opensearch = {
    provisioner = "existing"
    host        = "opensearch.example"
    port        = "443"
    scheme      = "https"
  }
}
```

## Add extra environment variables

You can add extra environment variables to the OpenMetadata pod by using the parameter `app_extra_envs`:

```hcl
module "omd" {
  source = "github.com/open-metadata/openmetadata-terraform//openmetadata-aws?ref=[version]"

  # Namespace where OpenMetadata and dependencies will be deployed
  app_namespace    = "example"

  # Version of OpenMetadata to deploy
  app_version      = "1.6"

  # Subnet IDs, used for the Airflow's EFS mount targets and EFS security group
  subnet_ids       = ["subnet-1a2b3c4d", "subnet-5e6f7g8h", "subnet-9i0j1k2l"]

  # VPC ID for the security groups of the EFS instances
  vpc_id = "vpc-1a2b3c4d"

  # Extra environment variables for the OpenMetadata pod
  app_extra_envs = {
    "VAR_1" = "foo"
    "VAR_2" = "bar"
  }
}
```

You can also add extra environment variables from Kubernetes secrets by using the parameter `app_env_from`:

```hcl
module "omd" {
  source = "github.com/open-metadata/openmetadata-terraform//openmetadata-aws?ref=[version]"

  # Namespace where OpenMetadata and dependencies will be deployed
  app_namespace    = "example"

  # Version of OpenMetadata to deploy
  app_version      = "1.6"

  # Subnet IDs, used for the Airflow's EFS mount targets and EFS security group
  subnet_ids       = ["subnet-1a2b3c4d", "subnet-5e6f7g8h", "subnet-9i0j1k2l"]

  # VPC ID for the security groups of the EFS instances
  vpc_id = "vpc-1a2b3c4d"

  # Extra environment variables for the OpenMetadata pod from Kubernetes secrets
  app_env_from = ["my-other-secret-1", "my-other-secret-2"]
}
```
