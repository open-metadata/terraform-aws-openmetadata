## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.openmetadata](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version) | Version of the OpenMetadata Helm chart to deploy. | `string` | `null` | no |
| <a name="input_helm_values"></a> [helm\_values](#input\_helm\_values) | Custom values to override the default values in the OpenMetadata Helm chart. | `any` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The OpenMetadata application's namespace. | `string` | `"openmetadata"` | no |

## Outputs

No outputs.