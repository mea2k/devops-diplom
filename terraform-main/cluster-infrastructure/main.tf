#######################################
# CLUSTER - ГРУППА УЗЛОВ MASTER
#######################################
## Образ загрузочного диска
data "yandex_compute_image" "boot" {
  family = var.vms_os_family
}
## Описание ВМ Master - VM_MASTER_COUNT штук типа "master" (см. var.vms_resources)
resource "yandex_compute_instance" "vm_master" {
  count = var.vm_master_count

  # из vms_resources берем элемент с именем 'master'
  name        = "${var.vm_master_name}-${count.index + 1}"
  hostname    = "${var.vm_master_name}-${count.index + 1}"
  zone        = var.vm_master_subnets[count.index].zone
  platform_id = var.vms_resources["master"].platform_id
  resources {
    cores         = var.vms_resources["master"].cores
    memory        = var.vms_resources["master"].memory
    core_fraction = var.vms_resources["master"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.boot.id
      size     = var.vms_resources["master"].hdd_size
      type     = var.vms_resources["master"].hdd_type
    }
  }
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }

  scheduling_policy {
    preemptible = var.vms_resources["master"].preemptible
  }
  network_interface {
    index     = 0
    subnet_id = var.vm_master_subnets[count.index].id
    nat       = var.vms_resources["master"].enable_nat
  }

  #######################################
  # TODO DEBUG
  # разрешение обновления ВМ "на лету"
  allow_stopping_for_update = true
  #######################################

  # metadata = {
  #   serial-port-enable = local.vms_metadata.serial_port_enable #1
  #   ssh-keys           = local.vms_metadata.ssh_keys[0]        #"ubuntu:${var.vms_ssh_root_key}"
  # }
  metadata = local.vms_metadata_public_image
}

#######################################
# CLUSTER - ГРУППА УЗЛОВ WORKER
#######################################
## Описание ВМ Worker - VM_WORKER_COUNT штук типа "worker" (см. var.vms_resources)
resource "yandex_compute_instance" "vm_worker" {
  count = var.vm_worker_count

  # из vms_resources берем элемент с именем 'worker'
  name        = "${var.vm_worker_name}-${count.index + 1}"
  hostname    = "${var.vm_worker_name}-${count.index + 1}"
  zone        = var.vm_worker_subnets[count.index].zone
  platform_id = var.vms_resources["worker"].platform_id
  resources {
    cores         = var.vms_resources["worker"].cores
    memory        = var.vms_resources["worker"].memory
    core_fraction = var.vms_resources["worker"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.boot.id
      size     = var.vms_resources["worker"].hdd_size
      type     = var.vms_resources["worker"].hdd_type
    }
  }
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }

  scheduling_policy {
    preemptible = var.vms_resources["worker"].preemptible
  }
  network_interface {
    index     = 0
    subnet_id = var.vm_worker_subnets[count.index].id
    nat       = var.vms_resources["worker"].enable_nat
  }

  #######################################
  # TODO DEBUG
  # разрешение обновления ВМ "на лету"
  allow_stopping_for_update = true
  #######################################

  # metadata = {
  #   serial-port-enable = local.vms_metadata.serial_port_enable #1
  #   ssh-keys           = local.vms_metadata.ssh_keys[0]        #"ubuntu:${var.vms_ssh_root_key}"
  # }
  metadata = local.vms_metadata_public_image
}

#######################################
# ФАЙЛ HOSTS.YAML ДЛЯ ANSIBLE
#######################################
## generate inventory file for Ansible
resource "local_file" "ansible_hosts" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    {
      vm_master = yandex_compute_instance.vm_master
      vm_worker = yandex_compute_instance.vm_worker
      ansible_user : var.vms_ssh_user
    }
  )
  filename = "${var.ansible_inventory_path}hosts.yml"
}

#######################################
# ПРОБРОС ПОРТОВ ДЛЯ SSH
#######################################
## Установка правил IPTABLES на всех NAT-INSTANCES
## Внешний порт - начиная с VAR.EXT_SSH_PORT и далее + 1
## если ssh_master_forward_enable стоит TRUE
resource "terraform_data" "iptables_rules" {
  count = var.ssh_master_forward_enable == true ? var.vm_master_count : 0

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo apt install -y iptables iptables-persistent",
      "sudo iptables -t nat -F PREROUTING",
      "sudo iptables -t nat -A PREROUTING -p tcp --dport ${local.master_ssh[count.index].nat_port} -j DNAT --to-destination ${local.master_ssh[count.index].ip}:22",
      "sudo iptables-save | sudo tee /etc/iptables/rules.v4",
    ]
    connection {
      type        = "ssh"
      host        = local.master_ssh[count.index].nat_ip
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
  depends_on = [yandex_compute_instance.vm_master]
}