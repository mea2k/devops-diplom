#######################################
# УСТАНОВКА PROMETHEUS
#######################################
## Менеджер уведомлений
resource "kubernetes_config_map" "alertmanager_config" {
  metadata {
    name      = "alertmanager-config"
    namespace = var.monitoring_namespace
  }

  data = {
    "alertmanager.yml" = file("${path.module}/values/alertmanager.yaml")
  }
}

## Установка kube-prometheus-stack
## через HELM
resource "helm_release" "prometheus" {
  name       = var.prometheus_name       #"prometheus"
  repository = var.prometheus_repo       #"https://prometheus-community.github.io/helm-charts"
  chart      = var.prometheus_chart_name #"kube-prometheus-stack"
  #version    = var.prometheus_chart_version
  namespace        = var.monitoring_namespace
  wait             = true
  create_namespace = false

  values = [
    file("${path.module}/values/prometheus.yaml")
  ]

  set {
    name  = "alertmanager.configFromSecret"
    value = kubernetes_config_map.alertmanager_config.metadata[0].name
  }

  set {
    name  = "serviceMonitor.enabled"
    value = true
  }
  set {
    name  = "serviceMonitor.namespace"
    value = var.monitoring_namespace
  }
}

data "kubernetes_service" "grafana" {
  metadata {
    name      = "${var.prometheus_name}-grafana"
    namespace = var.monitoring_namespace
  }
}