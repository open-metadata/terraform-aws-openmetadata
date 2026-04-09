# Complete example for OpenMetadata deployment on AWS

This example creates a fully operational environment on AWS, for deploying **OpenMetadata** with additional supporting infrastructure.

Note that 💸 **it creates resources which will incur monetary charges** 💸 on your AWS bill.

Run 💣 **terraform destroy** 💣 when you no longer need them.


## Resources Created

Configuration in this folder creates:

* One **VPC**, with public and private subnets, one Internet Gateway and a single NAT Gateway.
* One **EKS cluster**, with the `aws-ebs-csi-driver` addon.
* One **node group** for the EKS cluster.
* Two **IAM roles** to use with the EKS cluster and the node group.
* One **KMS key** to encrypt resources and volumes.
* One **OpenSearch domain** to use as search engine with a Security Group allowing inbound connections from the EKS nodes.
* One **RDS instance** with Multi-Zone and deletion protection enabled with a Security Group allowing inbound connections from the EKS nodes. Used by OpenMetadata.

Also, it deploys:

* **Metrics Server** on the EKS cluster via Helm.
* One encrypted **Kubernetes Storage Class** set as the default.
* One **Kubernetes namespace** to deploy the resources.
* **Kubernetes Secrets** to store database credentials and extra environment variables for OpenMetadata.
* Our [OpenMetadata dependencies Helm chart](https://github.com/open-metadata/openmetadata-helm-charts/tree/main/charts/deps) without Airflow (using the OMJob operator for ingestion).
* **OpenMetadata** [via Helm](https://github.com/open-metadata/openmetadata-helm-charts/tree/main/charts/openmetadata)

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```
