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

Using `helm` as provisioner for all components:

```hcl
module "omd" {
  source = "github.com/open-metadata/openmetadata-terraform//openmetadata-aws?ref=[version]"

  app_namespace    = "example" 
  app_version      = "1.6"
  eks_cluster_name = "my-eks-cluster"
  eks_nodes_sg_ids = ["sg-1234abcd5678efgh", "sg-8765ijkl4321mnop"]
  kms_key_id       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  region           = "us-east-1"                                                                                                                                                                                                                    
  subnet_ids       = ["subnet-1a2b3c4d", "subnet-5e6f7g8h", "subnet-9i0j1k2l"]
  vpc_id           = "vpc-1a2b3c4d"
}
```

Using `aws` as provisioner for all possible components:

```hcl
module "omd" {
  source = "github.com/open-metadata/openmetadata-terraform//openmetadata-aws?ref=[version]"
  
  app_namespace    = "example" 
  app_version      = "1.6"
  eks_cluster_name = "my-eks-cluster"
  eks_nodes_sg_ids = ["sg-1234abcd5678efgh", "sg-8765ijkl4321mnop"]
  kms_key_id       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  region           = "us-east-1"                                                                                                                                                                                                                    
  subnet_ids       = ["subnet-1a2b3c4d", "subnet-5e6f7g8h", "subnet-9i0j1k2l"]
  vpc_id           = "vpc-1a2b3c4d"

  db = {
    provisioner = "aws"
  }
  airflow = {
    db = {
      provisioner = "aws"
    }
  }
  opensearch = {
    provisioner = "aws"
  }
}
```

Using `existing` as provisioner for all possible components:

```hcl
module "omd" {
  source = "github.com/open-metadata/openmetadata-terraform//openmetadata-aws?ref=[version]"

  app_namespace    = "example"
  app_version      = "1.6"
  eks_cluster_name = "my-eks-cluster"                                                                                                                                                                                                               
  eks_nodes_sg_ids = ["sg-1234abcd5678efgh", "sg-8765ijkl4321mnop"]
  kms_key_id       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  region           = "us-east-1"
  subnet_ids       = ["subnet-1a2b3c4d", "subnet-5e6f7g8h", "subnet-9i0j1k2l"]
  vpc_id           = "vpc-1a2b3c4d"

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

  opensearch = {
    provisioner = "existing"
    host        = "opensearch.example"
    port        = "443"
    scheme      = "https"
  }
}
```

