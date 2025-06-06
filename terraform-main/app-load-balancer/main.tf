#######################################
# APPLICATION LOAD BALANCER
#######################################
# Целевая группа для балансировщика нагрузки. 
# Содержит список целевых экземпляров, на которые будет распределяться трафик. 
# Группа автоматически обновляется при изменении состава instance group.
resource "yandex_alb_target_group" "app-balancer-group" {
  name = "${var.app_balancer_name}-balancer-group"

  # Динамическое создание таргетов на основе всех VM Master
  dynamic "target" {
    for_each = var.vm_master
    content {
      # Использование общей подсети для всех экземпляров
      subnet_id = target.value.network_id
      # Получение внутреннего IP-адреса экземпляра из network interface
      ip_address = target.value.ip
      #region_id = target.value.zone
    }
  }
}

#Бэкенд группа определяет параметры балансировки трафика и проверки состояния инстансов
resource "yandex_alb_backend_group" "backend-group" {
  for_each = { for v in var.app_balancer_ports: "${v.from}" => v }
  name = "${var.app_balancer_name}-backend-group-${each.value.from}"

  # Включение привязки сессии к IP-адресу клиента для сохранения состояния
  session_affinity {
    connection {
      source_ip = true
    }
  }

  # Конфигурация HTTP-бэкенда
  http_backend {
    name   = "http-backend-${each.value.from}"
    weight = 1  # Вес для балансировки (при наличии нескольких бэкендов)
    port   = each.value.to # Порт целевых инстансов
    # Связь с целевой группой
    target_group_ids = [yandex_alb_target_group.app-balancer-group.id]

    # Конфигурация балансировки нагрузки
    load_balancing_config {
      panic_threshold = 90 # Порог для перехода в аварийный режим (% недоступных бэкендов)
      locality_aware_routing_percent = 70 # Percent of traffic to be sent to the same availability zone. The rest will be equally divided between other zones.
      strict_locality = false # If set, will route requests only to the same availability zone. Balancer won't know about endpoints in other zones.
      mode = "ROUND_ROBIN"   # Load balancing mode for the backend. Possible values: "ROUND_ROBIN", "RANDOM", "LEAST_REQUEST", "MAGLEV_HASH".
    }

    # Настройки проверки инстансов
    healthcheck {
      timeout             = "10s" # Максимальное время ожидания ответа
      interval            = "5s"  # Интервал между проверками
      healthy_threshold   = 10    # Число успешных проверок для признания работоспособности
      unhealthy_threshold = 5    # Число неудачных проверок для признания неработоспособности
      healthcheck_port = var.app_balancer_healthcheck_port
      http_healthcheck {
        path = var.app_balancer_healthcheck_url   # URL для проверки здоровья
      }
    }
  }

  # # Конфигурация HTTP-бэкенда
  # # Динамическое создание на основе всех портов
  # # из var.app_balancer_ports
  # dynamic "http_backend" {
  #   for_each = var.app_balancer_ports
  #   content {
  #     name   = "${var.app_balancer_name}-http-backend-${http_backend.value.from}"
  #     weight = 1                     # Вес для балансировки (при наличии нескольких бэкендов)
  #     port   = http_backend.value.to # Порт целевых инстансов
  #     # Связь с целевой группой
  #     target_group_ids = [yandex_alb_target_group.app-balancer-group.id]
  #     # Конфигурация балансировки нагрузки
  #     load_balancing_config {
  #       panic_threshold                = 80            # Порог для перехода в аварийный режим (% недоступных бэкендов)
  #       locality_aware_routing_percent = 70            # Percent of traffic to be sent to the same availability zone. The rest will be equally divided between other zones.
  #       strict_locality                = false         # If set, will route requests only to the same availability zone. Balancer won't know about endpoints in other zones.
  #       mode                           = "ROUND_ROBIN" # Load balancing mode for the backend. Possible values: "ROUND_ROBIN", "RANDOM", "LEAST_REQUEST", "MAGLEV_HASH".
  #     }
  #     # Настройки проверки инстансов
  #     # healthcheck {
  #     #   timeout             = "10s" # Максимальное время ожидания ответа
  #     #   interval            = "5s"  # Интервал между проверками
  #     #   healthy_threshold   = 10    # Число успешных проверок для признания работоспособности
  #     #   unhealthy_threshold = 5    # Число неудачных проверок для признания неработоспособности
  #     #   healthcheck_port = var.app_balancer_healthcheck_port

  #     #   http_healthcheck {
  #     #     path = var.app_balancer_healthcheck_url   # URL для проверки здоровья
  #     #   }
  #     # }
  #   }
  # }
}





# # Бэкенд группа определяет параметры балансировки трафика и проверки состояния инстансов
# resource "yandex_alb_backend_group" "backend-group" {
#   name = "${var.app_balancer_name}-backend-group"

#   # Включение привязки сессии к IP-адресу клиента для сохранения состояния
#   session_affinity {
#     connection {
#       source_ip = true
#     }
#   }

#   # Конфигурация HTTP-бэкенда
#   http_backend {
#     name   = "http-backend"
#     weight = 1  # Вес для балансировки (при наличии нескольких бэкендов)
#     #port   = 6443 # Порт целевых инстансов
#     # Связь с целевой группой
#     target_group_ids = [yandex_alb_target_group.app-balancer-group.id]
#     # Конфигурация балансировки нагрузки
#     load_balancing_config {
#       panic_threshold = 90 # Порог для перехода в аварийный режим (% недоступных бэкендов)
#       locality_aware_routing_percent = 70 # Percent of traffic to be sent to the same availability zone. The rest will be equally divided between other zones.
#       strict_locality = false # If set, will route requests only to the same availability zone. Balancer won't know about endpoints in other zones.
#       mode = "ROUND_ROBIN"   # Load balancing mode for the backend. Possible values: "ROUND_ROBIN", "RANDOM", "LEAST_REQUEST", "MAGLEV_HASH".
#     }
#     # Настройки проверки инстансов
#     healthcheck {
#       timeout             = "10s" # Максимальное время ожидания ответа
#       interval            = "5s"  # Интервал между проверками
#       healthy_threshold   = 10    # Число успешных проверок для признания работоспособности
#       unhealthy_threshold = 5    # Число неудачных проверок для признания неработоспособности
#       healthcheck_port = var.app_balancer_healthcheck_port

#       http_healthcheck {
#         path = var.app_balancer_healthcheck_url   # URL для проверки здоровья
#       }
#     }
#   }

#   # Зависимость от создания целевой группы
#   depends_on = [
#     yandex_alb_target_group.app-balancer-group
#   ]
# }

## HTTP-роутер для управления маршрутизацией запросов
resource "yandex_alb_http_router" "http-router" {
  for_each = { for v in var.app_balancer_ports: "${v.from}" => v }
  name = "${var.app_balancer_name}-http-router-${each.key}"
}

# Виртуальный хост для обработки входящих запросов
resource "yandex_alb_virtual_host" "app-balancer-host" {
  for_each = { for v in var.app_balancer_ports: "${v.from}" => v }
  name           = "${var.app_balancer_name}-balancer-host-${each.key}"
  http_router_id = yandex_alb_http_router.http-router["${each.key}"].id

  # Условие срабатывания маршрута виртуального хоста
  #authority = [ "vhost-${each.key}" ]
  
  # Удаляем модифицированный/добавленный заголовок
  # modify_response_headers {
  #   name = "modify-header-policy-${each.key}"  
  #   remove = true 
  # }

  # Правило маршрутизации для всех HTTP-запросов
  route {
    name = "route-http"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group["${each.key}"].id # Связь с бэкенд-группой
        timeout          = "60s"                                     # Таймаут обработки запроса
        #host_rewrite    = "vhost-${each.key}" # Здесь изменяем Host header
      }
    }
  }

  # # Ограничение запросов
  # rate_limit {
  #   ## частота всех запросов
  #   all_requests {
  #     per_second = 2
  #   }
  #   ## частота запросов от одного IP
  #   requests_per_ip {
  #     per_second  = 1
  #   }
  # }

}

## Группа логов - создание объекта Yadnex CLoud
resource "yandex_logging_group" "log_group" {
  count = var.app_balancer_enable_logging == true ? 1 : 0

  name             = "${var.app_balancer_name}-log-group"
  retention_period = "168h" # 1 week
}

## Основной ресурс Application Load Balancer
resource "yandex_alb_load_balancer" "app-balancer" {
  name       = var.app_balancer_name
  network_id = var.vpc_network_id # Идентификатор облачной сети

  # Политика распределения ресурсов балансировщика
  allocation_policy {
    dynamic "location" {
      for_each = var.vpc_public_subnets
      content {
        zone_id   = location.value.zone # зона
        subnet_id = location.value.id   # public-подсеть в этой зоне
      }
    }
  }

  # Конфигурация обработчика входящих запросов
  # создаем обработчика на каждый порт
  dynamic "listener" {
      for_each = { for v in var.app_balancer_ports: "${v.from}" => v }
      content {
        name = "${var.app_balancer_name}-listener-${listener.key}"
        endpoint {
          address {
            external_ipv4_address {
              address = yandex_vpc_address.public_ip.external_ipv4_address[0].address
            }
          }
          ports = [ listener.value.from ]
        }
        http {
          handler {
            http_router_id = yandex_alb_http_router.http-router["${listener.key}"].id # Привязка HTTP-роутера
            rewrite_request_id = true
          }
        }
      }
    }

  # listener {
  #   name = "${var.app_balancer_name}-listener"
  #   endpoint {
  #     address {
  #       external_ipv4_address {
  #         address = yandex_vpc_address.public_ip.external_ipv4_address[0].address
  #       }
  #     }
  #     ports = [for s in var.app_balancer_ports : s.from]
  #   }
  #   http {
  #     handler {
  #       http_router_id = yandex_alb_http_router.http-router.id # Привязка HTTP-роутера
  #       rewrite_request_id = true
  #     }
  #   }
  # }

  
  dynamic "log_options" {
    for_each = yandex_logging_group.log_group 
    content {
      log_group_id = log_options.value.id

      discard_rule {
        http_code_intervals = ["HTTP_2XX"]
        discard_percent     = 80
      }
    }
  }

  # Зависимость от создания HTTP-роутера
  depends_on = [
    yandex_alb_http_router.http-router,
    yandex_alb_virtual_host.app-balancer-host,
  ]
}

## Внешний IP-адрес балансировщика
resource "yandex_vpc_address" "public_ip" {
  name = "${var.app_balancer_name}-public-ip"

  external_ipv4_address {
    zone_id = var.vpc_public_subnets[0].zone
  }
}
