locals {
  airflow_efs_instances = var.airflow.storage

  # Map to combine EFS instances with subnets to ease the creation of mount targets
  # e.g.
  #
  #flattened_instance_subnet_map = {
  #  "dags/subnet_1" = {
  #      instance  = "dags"
  #      subnet_id = "subnet-abc123def456ghi78"
  #  }
  #  "dags/subnet_2" = {
  #      instance  = "dags"
  #      subnet_id = "subnet-def456ghi78jkl901"
  #  }
  #  "dags/subnet_3" = {
  #      instance  = "dags"
  #      subnet_id = "subnet-ghi78jkl901mno234"
  #  }
  #  "logs/subnet_1" = {
  #      instance  = "logs"
  #      subnet_id = "subnet-abc123def456ghi78"
  #  }
  #  "logs/subnet_2" = {
  #      instance  = "logs"
  #      subnet_id = "subnet-def456ghi78jkl901"
  #  }
  #  "logs/subnet_3" = {
  #      instance  = "logs"
  #      subnet_id = "subnet-ghi78jkl901mno234"
  #  }
  #}
  flattened_instance_subnet_map = {
    for combination in flatten([
      for instance, _ in local.airflow_efs_instances : [
        for idx, subnet_id in var.subnet_ids : {
          key       = "${instance}/subnet_${idx + 1}"
          instance  = instance
          subnet_id = subnet_id
        }
      ]
      ]) : combination.key => {
      instance  = combination.instance
      subnet_id = combination.subnet_id
    }
  }
}

resource "aws_efs_file_system" "airflow" {
  for_each = local.airflow_efs_instances

  creation_token = "airflow-${each.key}"
  encrypted      = true
  kms_key_id     = var.kms_key_id
}

module "sg_efs" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>5.2"

  name        = "airflow-efs"
  description = "Allow inbound NFS traffic from EKS nodes"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [for sg_id in var.eks_nodes_sg_ids :
    {
      from_port                = 2049
      to_port                  = 2049
      protocol                 = "tcp"
      description              = "NFS from ${sg_id}"
      source_security_group_id = sg_id
    }
  ]
}

resource "aws_efs_mount_target" "airflow" {
  for_each = local.flattened_instance_subnet_map

  file_system_id  = aws_efs_file_system.airflow[each.value.instance].id
  subnet_id       = each.value.subnet_id
  security_groups = [module.sg_efs.security_group_id]
}

resource "kubernetes_storage_class_v1" "airflow_efs" {
  for_each = local.airflow_efs_instances

  metadata {
    name = "efs-${each.key}"
  }
  storage_provisioner = "efs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.airflow[each.key].id
    directoryPerms   = "700"
    encrypted        = "true"
    kmsKeyId         = var.kms_key_id
  }
}

resource "kubernetes_persistent_volume_v1" "airflow" {
  for_each = local.airflow_efs_instances

  metadata {
    name = var.airflow.pvc[each.key]
    labels = {
      app = var.airflow.pvc[each.key]
    }
  }

  spec {
    capacity = {
      storage = each.value
    }
    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "efs-${each.key}"
    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = aws_efs_file_system.airflow[each.key].id
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "airflow" {
  for_each = local.airflow_efs_instances

  metadata {
    name      = var.airflow.pvc[each.key]
    namespace = var.namespace
    labels = {
      app = var.airflow.pvc[each.key]
    }
  }
  wait_until_bound = false
  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = each.value
      }
    }
    storage_class_name = "efs-${each.key}"
  }
}
