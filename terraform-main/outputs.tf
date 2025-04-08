
output "Network" {
  value = {
    net : module.net.net,
    public : module.net.public,
    private : module.net.private
  }
}
output "vm_master" {
  value = [for s in module.cluster-infrastructure.vm_master : {
    vm = {
      fqdn   = s.fqdn,
      id     = s.id,
      name   = s.name,
      ip     = s.network_interface[length(s.network_interface) - 1].ip_address,
      nat_ip = s.network_interface[length(s.network_interface) - 1].nat_ip_address,
      zone   = s.zone
    },
    external = "ssh -o 'StrictHostKeyChecking=no' ${var.vms_ssh_user}@${s.network_interface[length(s.network_interface) - 1].nat_ip_address}",
  }]
}

output "vm_worker" {
  value = [for s in module.cluster-infrastructure.vm_worker : {
    vm = {
      fqdn   = s.fqdn,
      id     = s.id,
      name   = s.name,
      ip     = s.network_interface[length(s.network_interface) - 1].ip_address,
      nat_ip = s.network_interface[length(s.network_interface) - 1].nat_ip_address,
      zone   = s.zone
    },
    internal = "ssh -o 'StrictHostKeyChecking=no' ${var.vms_ssh_user}@${s.network_interface[length(s.network_interface) - 1].ip_address}",
  }]
}

output "route_table" {
  value = module.net.route_table
}

output "vm_nat" {
  value = [for s in module.net.vm_nat : {
    vm = {
      fqdn   = s.fqdn,
      id     = s.id,
      name   = s.name,
      ip     = s.network_interface[length(s.network_interface) - 1].ip_address,
      nat_ip = s.network_interface[length(s.network_interface) - 1].nat_ip_address,
      zone   = s.zone
    }, }
  ]
}

output "vm_control" {
  value = [for s in module.vm-control.vm_control : {
    vm = {
      fqdn   = s.fqdn,
      id     = s.id,
      name   = s.name,
      ip     = s.network_interface[length(s.network_interface) - 1].ip_address,
      nat_ip = s.network_interface[length(s.network_interface) - 1].nat_ip_address,
      zone   = s.zone
    },
    external = "ssh -o 'StrictHostKeyChecking=no' ${var.vms_ssh_user}@${s.network_interface[length(s.network_interface) - 1].nat_ip_address}",
  }]
}