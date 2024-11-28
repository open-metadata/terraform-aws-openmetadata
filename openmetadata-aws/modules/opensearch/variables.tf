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
  description = "Namespace to deploy the Kubernetes secret. Must be the OpenMetadata application's namespace."
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets IDs where the databases and OpenSearch will be deployed. The recommended configuration is to use private subnets."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy the databases and OpenSearch. For example: `vpc-xxxxxxxx`."
}

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
      username = optional(string)     # OpenSearch username
      password = optional(object({    # Password secret
        secret_ref = optional(string) # Secret reference for OpenSearch password
        secret_key = optional(string) # Secret key for OpenSearch password
      }))
    }))
    volume_size = optional(number) # OpenSearch storage size in GB
  })
}
