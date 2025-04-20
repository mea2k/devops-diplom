output "prometheus" {
  value = {
    url     = module.prometheus-stack.prometheus_url,
    command = module.prometheus-stack.access_commands
  }
}

# output "grafana" {
#   value = {
#   grafana_admin_password: module.grafana.grafana_admin_password,
#   grafana_url: module.grafana.grafana_url,
#   access_commands: module.grafana.access_commands
#   }
#   sensitive = true
# }
