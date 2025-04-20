#######################################
# УСТАНОВКА GRAFANA
#######################################
## Установка grafana
## через HELM
resource "helm_release" "grafana" {
  name       = var.grafana_name       #"grafana"
  repository = var.grafana_repo       #"https://grafana.github.io/helm-charts"
  chart      = var.grafana_chart_name #"grafana"
  version    = var.grafana_chart_version
  namespace  = var.monitoring_namespace

  set {
    name  = "adminPassword"
    value = var.grafana_admin_password != "" ? var.grafana_admin_password : random_password.grafana_password.result
  }

  values = [
    file("${path.module}/values/grafana.yaml")
  ]

}

# Генерируем случайный пароль для Grafana, если не указан
resource "random_password" "grafana_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Настраиваем Ingress для Grafana (опционально)
resource "kubernetes_ingress_v1" "grafana_ingress" {
  count = var.enable_ingress ? 1 : 0

  metadata {
    name      = "grafana-ingress"
    namespace = var.monitoring_namespace
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      host = var.ingress_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

}
