locals {
  airflow_efs_instances            = var.airflow.storage
  airflow_efs_create_mount_targets = { for pair in local.efs_mount_targets.map : "${pair.instance}/${pair.subnet_id}" => pair }
  subnets_cidr_blocks              = [for subnet in var.subnet_ids : data.aws_subnet.this[subnet].cidr_block]

  efs_mount_targets = {
    map = flatten([
      for instance, size in local.airflow_efs_instances : [
        for subnet_id in var.subnet_ids : {
          instance  = instance
          subnet_id = subnet_id
        }
      ]
    ])
  }
}

resource "aws_efs_file_system" "airflow" {
  for_each = local.airflow_efs_instances

  creation_token = "airflow-${each.key}"
  encrypted      = true
  kms_key_id     = var.kms_key_id
}

resource "aws_security_group" "airflow_efs" {
  name        = "airflow-efs"
  description = "Allow inbound NFS traffic from the provided subnets."
  vpc_id      = var.vpc_id

  ingress {
    cidr_blocks = local.subnets_cidr_blocks
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
  }
}

resource "aws_efs_mount_target" "airflow" {
  for_each = local.airflow_efs_create_mount_targets

  file_system_id  = aws_efs_file_system.airflow[each.value.instance].id
  subnet_id       = each.value.subnet_id
  security_groups = [aws_security_group.airflow_efs.id]
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
