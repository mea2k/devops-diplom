output "alb" {
  value = yandex_alb_load_balancer.app-balancer
}

output "alb_info" {
  value = {
    name : yandex_alb_load_balancer.app-balancer.name,
    address : yandex_alb_load_balancer.app-balancer.listener[0].endpoint[0].address[0].external_ipv4_address[0].address,
    ports : yandex_alb_load_balancer.app-balancer.listener[0].endpoint[0].ports
  }
}
