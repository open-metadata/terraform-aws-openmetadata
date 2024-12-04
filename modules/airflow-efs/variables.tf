variable "airflow" {
  description = "Airflow configuration."
  type = object({
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

variable "eks_nodes_sg_ids" {
  type        = list(string)
  description = "List of security group IDs attached to the EKS nodes. Allows traffic from them to the EFS instances."
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy the resources."
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
