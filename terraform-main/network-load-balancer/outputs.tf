output "nlb" {
  value = yandex_lb_network_load_balancer.kube_ext_nlb
}

output "nlb_info" {
  value = {
    name : yandex_lb_network_load_balancer.kube_ext_nlb.name,
    address : var.enable_public_ip == true ? yandex_vpc_address.public_ip[0].external_ipv4_address[0].address : null,
    ext_port : tolist(yandex_lb_network_load_balancer.kube_ext_nlb.listener)[0].port
    target_port : tolist(yandex_lb_network_load_balancer.kube_ext_nlb.listener)[0].target_port
  }
}

output "public_ip" {
  value = yandex_vpc_address.public_ip[0]
}