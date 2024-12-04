variable "helm_chart_version" {
  type        = string
  description = "Version of the OpenMetadata dependencies Helm chart to deploy."
  default     = null
}

variable "helm_values" {
  type        = any
  description = "Custom values to override the default values in the OpenMetadata dependencies Helm chart."
  default     = null
}

variable "namespace" {
  type        = string
  default     = "openmetadata"
  description = "The OpenMetadata application's namespace."
}
