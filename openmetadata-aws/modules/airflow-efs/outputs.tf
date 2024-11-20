output "pvcs" {
  value = {
    for key, pvc in kubernetes_persistent_volume_claim_v1.airflow :
    key => pvc.metadata[0].name
  }
}
