#######################################
# СОЗДАНИЕ NAMESPACE
#######################################
## Создание namespace MONITORING
resource "kubernetes_namespace" "chart_namespace" {
  metadata {
    name = var.chart_namespace
  }
}

#######################################
# УСТАНОВКА CHART-а
#######################################
## Установка через HELM
resource "helm_release" "chart" {
  name       = var.chart_name
  repository = var.chart_repo_url
  chart      = var.chart_repo_name
  version    = var.chart_version
  namespace  = var.chart_namespace

  values = [
    file("${var.additional_settings_file}")
  ]

  depends_on = [kubernetes_namespace.chart_namespace]
}
