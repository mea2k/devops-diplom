#######################################
# БАЛАНСИРОВЩИК ОТ YANDEX CLOUD
#######################################
## балансировшик уровня 4 (транспортный)
## Внешний
resource "yandex_lb_network_load_balancer" "kube_ext_nlb" {
  name = "${var.nlb_name}-ext"

  # external is by default
  type = "external"

  # Разрешаем смену зон
  #allow_zonal_shift = true

  #external
  listener {
    name        = "${var.nlb_name}-ext-listener-port-${var.nlb_ext_port}"
    port        = var.nlb_ext_port
    target_port = var.nlb_int_port
    external_address_spec {
      ip_version = var.ip_version
      address    = (var.public_ip != null && var.public_ip != "") ? var.public_ip : yandex_vpc_address.public_ip[0].external_ipv4_address[0].address
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.kube_nlb_target_group.id

    healthcheck {
      name = "http"
      http_options {
        port = var.nlb_healthcheck_port
        path = var.nlb_healthcheck_url #"/api"
      }
      # tcp_options {
      #   port = 22 #ssh
      # }
    }
  }
}

## Группа серверов для балансировки - все ВМ Master
resource "yandex_lb_target_group" "kube_nlb_target_group" {

  name = "${var.nlb_name}-target-group"

  dynamic "target" {
    for_each = var.vm_master
    content {
      subnet_id = target.value.network_id
      address   = target.value.ip
    }
  }
}

## Внешний IP-адрес балансировщика
resource "yandex_vpc_address" "public_ip" {
  count = (var.enable_public_ip == true && (var.public_ip == null || var.public_ip == "")) ? 1 : 0

  name = "${var.nlb_name}-public-ip"

  external_ipv4_address {
    zone_id = var.public_ip_zone
  }
}
