output "prometheus_url" {
  description = "Prometheus web UI URL"
  value       = "http://prometheus.${var.monitoring_namespace}.svc.cluster.local:9090"
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