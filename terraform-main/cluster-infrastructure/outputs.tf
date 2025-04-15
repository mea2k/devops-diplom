# Информация о созданных ВМ Master
output "vm_master" {
  value = [for s in yandex_compute_instance.vm_master : {
    fqdn       = s.fqdn,
    id         = s.id,
    name       = s.name,
    ip         = s.network_interface[length(s.network_interface) - 1].ip_address,
    nat_ip     = s.network_interface[length(s.network_interface) - 1].nat_ip_address,
    zone       = s.zone,
    network_id = s.network_interface[length(s.network_interface) - 1].subnet_id
    }
  ]
}

# Информация о созданных ВМ Worker
output "vm_worker" {
  value = [for s in yandex_compute_instance.vm_worker : {
    fqdn       = s.fqdn,
    id         = s.id,
    name       = s.name,
    ip         = s.network_interface[length(s.network_interface) - 1].ip_address,
    nat_ip     = s.network_interface[length(s.network_interface) - 1].nat_ip_address,
    zone       = s.zone,
    network_id = s.network_interface[length(s.network_interface) - 1].subnet_id
    }
  ]
}

# Строки подключения по SSH к ВМ Master
# с использованием Port Forwarding
output "master_ssh" {
  value = local.master_ssh
}
