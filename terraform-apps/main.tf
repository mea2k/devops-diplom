#######################################
# СОЗДАНИЕ NAMESPACE
#######################################
## Создание namespace MONITORING
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
  }
}

#######################################
# МОДУЛЬ PROMETHEUS + GRAFANA + ALERT_MANAGER
#######################################
module "prometheus-stack" {
  source = "./prometheus-stack"

  # Переменные модуля

  ## Пространство имен (namrspace) в кластере
  monitoring_namespace = kubernetes_namespace.monitoring.metadata[0].name

  ## Имя сервиса
  prometheus_name = "prometheus"

  ## Остальное по умолчанию

  ## Prometheus repository
  #prometheus_repo= "https://prometheus-community.github.io/helm-charts"

  ## Prometheus helm chart name
  #prometheus_chart_name = "kube-prometheus-stack"

  ## Prometheus helm chart version
  prometheus_chart_version = "56.6.0" #"70.5.0" 

  depends_on = [kubernetes_namespace.monitoring]
}

#######################################
# МОДУЛЬ GRAFANA
#######################################
# module "grafana" {
#   source = "./grafana"

#   # Переменные модуля

#   ## Пространство имен (namrspace) в кластере
#   monitoring_namespace = "monitoring"

#   ## Имя сервиса
#   grafana_name = "grafana"

#   ## Grafana helm chart name
#   grafana_chart_name = "grafana"    #"k8s-monitoring"

#   ## Grafana admin password
#   grafana_admin_password = ""

#   ## Enable ingress
#   enable_ingress = true
#   ingress_host = "localhost"

#   ## Остальное по умолчанию

#   ## Grafana repository
#   #grafana_repo= "https://grafana.github.io/helm-charts"

#   ## Prometheus helm chart version
#   #grafana_chart_version = "7.0.0"

#   depends_on = [ kubernetes_namespace.monitoring ]
# }