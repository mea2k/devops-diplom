#######################################
# NAMESPACE
#######################################
## Namespace MONITORING
variable "monitoring_namespace" {
  type        = string
  description = "Monitoring namespace name"
}

#######################################
# PROMETHEUS
#######################################
## Prometheus name
variable "prometheus_name" {
  type        = string
  description = "Prometheus name"
  default     = "prometheus"
}
## Prometheus repository
variable "prometheus_repo" {
  type        = string
  description = "Prometheus helm repository"
  default     = "https://prometheus-community.github.io/helm-charts"
}
## Prometheus helm chart name
variable "prometheus_chart_name" {
  type        = string
  description = "Prometheus helm chart name"
  default     = "kube-prometheus-stack"
}
## Prometheus helm chart version
variable "prometheus_chart_version" {
  type        = string
  description = "Prometheus helm chart version"
  default     = null # "70.5.0"
}
