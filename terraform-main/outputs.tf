output "Network" {
  value = {
    net : module.net.net,
    public : module.net.public,
    private : module.net.private
  }
}

output "VMs" {
  value = {
    vm_master : [for s in module.cluster-infrastructure.vm_master : {
      vm       = s,
      internal = "ssh -o 'StrictHostKeyChecking=no' ${var.vms_ssh_user}@${s.nat_ip != "" ? s.nat_ip : s.ip}",
    }],
    vm_master_ssh : [for s in module.cluster-infrastructure.master_ssh : {
      name : s.name,
      external : "ssh -o 'StrictHostKeyChecking=no' ${var.vms_ssh_user}@${s.nat_ip} -p ${s.nat_port}",
    }],
    vm_worker : [for s in module.cluster-infrastructure.vm_worker : {
      vm       = s,
      internal = "ssh -o 'StrictHostKeyChecking=no' ${var.vms_ssh_user}@${s.ip}",
    }]
  }
}

output "vm_nat" {
  value = [for s in module.net.vm_nat : {
    name : s.name,
    zone : s.zone,
    external : "ssh -o 'StrictHostKeyChecking=no' ${var.vms_ssh_user}@${s.nat_ip}"
  }]
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


output "nlb" {
  value = module.kube-nlb.nlb
}

output "alb" {
  value = module.kube-alb.alb
}