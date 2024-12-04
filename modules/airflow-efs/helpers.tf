resource "kubernetes_job_v1" "efs_provision" {
  for_each = toset(var.enable_helpers ? ["this"] : [])

  metadata {
    name      = "efs-provision"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {
        labels = {
          app = "efs-provision"
        }
      }
      spec {
        container {
          image = "busybox:latest"
          name  = "efs-provision"
          env {
            name  = "DAGS_SUBPATH"
            value = var.airflow.subpath.dags
          }
          env {
            name  = "LOGS_SUBPATH"
            value = var.airflow.subpath.logs
          }
          command = [
            "sh", "-c",
            "mkdir -p /efs/airflow-dags/$${DAGS_SUBPATH} /efs/airflow-logs/$${LOGS_SUBPATH}; chown -R 50000 /efs/airflow-dags/$${DAGS_SUBPATH} /efs/airflow-logs/$${LOGS_SUBPATH} && chmod -R a+rwx /efs/airflow-dags/$${DAGS_SUBPATH}"
          ]
          volume_mount {
            name       = "airflow-dags"
            mount_path = "/efs/airflow-dags"
          }
          volume_mount {
            name       = "airflow-logs"
            mount_path = "/efs/airflow-logs"
          }
        }
        volume {
          name = "airflow-dags"
          persistent_volume_claim {
            claim_name = var.airflow.pvc.dags
          }
        }
        volume {
          name = "airflow-logs"
          persistent_volume_claim {
            claim_name = var.airflow.pvc.logs
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = false
  depends_on = [
    kubernetes_persistent_volume_v1.airflow,
    kubernetes_persistent_volume_claim_v1.airflow,
    kubernetes_storage_class_v1.airflow_efs,
    aws_efs_mount_target.airflow,
    aws_efs_file_system.airflow,
  ]
}
