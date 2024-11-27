# Complete example for OpenMetadata deployment on AWS

This example creates a fully operational environment on AWS, for deploying **OpenMetadata** with additional supporting infrastructure.

Note that 💸 **it creates resources which will incur monetary charges** 💸 on your AWS bill.

Run 💣 **terraform destroy** 💣 when you no longer need them.


## Resources Created

Configuration in this folder creates:

* One **VPC**, with public and private subnets, one Internet Gateway and a single NAT Gateway.
* One **EKS cluster**, with `aws-ebs-csi-driver` and `aws-efs-csi-driver` addons.
* One **node group** for the EKS cluster.
* Two **IAM roles** to use with the EKS cluster and the node group.
* One **KMS_KEY** to encrypt resources and volumes.
* One `OpenSearch domain` to use as search engine with a Security Group allowing inbound connections from the EKS nodes.
* Two `RDS instances` with Multi-Zone and deletion protection enabled with Security Groups allowing inbound connections from the EKS nodes. Will be used by OpenMetadata and Airflow.
* Two **EFS volumes**, each one with mount targets on the private subnets, and a Security Group allowing inbound connections from the EKS nodes. Will be used by Airflow `dags` and `logs`.

Also, it deploys:

* **Metrics Server** on the EKS cluster via Helm.
* Three encrypted **Kubernetes Storage Class** to use as default option and with both **EFS volumes**.
* One **Kubernetes namespace** to deploy the resouces.
* **Kubernetes Secrets** to store database credentials, Airflow authentication, and extra environment variables to use with OpenMetadata.
* Our [OpenMetadata dependencies Helm chart](https://github.com/open-metadata/openmetadata-helm-charts/tree/main/charts/deps) only with **Airflow** enabled.
* **OpenMetadata** [via Helm](https://github.com/open-metadata/openmetadata-helm-charts/tree/main/charts/openmetadata)

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```
