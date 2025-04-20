#######################################
# NAMESPACE
#######################################
## Namespace MONITORING
variable "monitoring_namespace" {
  type        = string
  description = "Monitoring namespace name"
}

#######################################
# GRAFANA
#######################################
## Grafana name
variable "grafana_name" {
  type        = string
  description = "Grafana name"
  default     = "grafana"
} ## Grafana repository
variable "grafana_repo" {
  type        = string
  description = "Grafana helm repository"
  default     = "https://grafana.github.io/helm-charts"
}
## Grafana helm chart name
variable "grafana_chart_name" {
  type        = string
  description = "Grafana helm chart name"
  default     = "grafana"
}
## Grafana helm chart version
variable "grafana_chart_version" {
  description = "Version of Grafana chart"
  type        = string
  default     = null #"6.56.4"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_ingress" {
  description = "Whether to enable Ingress for Grafana"
  type        = bool
  default     = false
}

variable "ingress_host" {
  description = "Ingress host for Grafana"
  type        = string
  default     = "localhost"
}