output "nlb" {
  value = yandex_lb_network_load_balancer.kube_ext_nlb
}

output "nlb_ext_ip" {
  value = var.enable_public_ip == true ? yandex_vpc_address.public_ip[0].external_ipv4_address[0].address : null
}
