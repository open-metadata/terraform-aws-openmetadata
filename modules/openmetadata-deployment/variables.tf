variable "helm_chart_version" {
  type        = string
  description = "Version of the OpenMetadata Helm chart to deploy."
  default     = null
}

variable "extra_helm_values" {
  type        = map(string)
  description = "Map of additional Helm set overrides. Keys are Helm value paths, values are strings."
  default     = {}
}

variable "helm_values" {
  type        = any
  description = "Custom values to override the default values in the OpenMetadata Helm chart."
  default     = null
}

variable "namespace" {
  type        = string
  default     = "openmetadata"
  description = "The OpenMetadata application's namespace."
}
