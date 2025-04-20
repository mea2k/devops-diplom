output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = var.grafana_admin_password != "" ? var.grafana_admin_password : random_password.grafana_password.result
  sensitive   = true
}

output "grafana_url" {
  description = "Grafana web UI URL"
  value       = var.enable_ingress ? "https://${var.ingress_host}" : "http://grafana.${var.monitoring_namespace}.svc.cluster.local:3000"
}

output "access_commands" {
  description = "Commands to access monitoring tools locally"
  value       = <<EOT
To access Prometheus locally:
kubectl port-forward -n ${var.monitoring_namespace} svc/prometheus-kube-prometheus-prometheus 9090:9090

To access Grafana locally:
kubectl port-forward -n ${var.monitoring_namespace} svc/grafana 3000:80
EOT
}