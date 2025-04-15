output "kubernetes_ext" {
  value = {
    ext_ip : var.loadbalancer_ext_ip,
    ext_port : var.loadbalancer_ext_port
  }
}