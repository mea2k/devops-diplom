#######################################
# ВМ ДЛЯ УПРАВЛЕНИЯ РЕСУРСАМИ
#######################################
## Образ загрузочного диска
data "yandex_compute_image" "vm_boot" {
  count = var.vm_control_enable == true ? 1 : 0

  family = var.vm_control_os_family
}


## Создание файла cloud-init из шаблона - 
## cloud-init/vm-control.yml
# resource "local_file" "cloud_init_file" {
#   content = templatefile("${path.module}/templates/vm-control.yml.tpl",
#     {
#       ssh_user = var.vms_ssh_user
#       ssh_root_key = var.vms_ssh_root_key
#     }
#   )
#   filename = "${path.module}/cloud-init/vm-control.yml"
# }

data "template_file" "cloud_init" {
  template = "${file("${path.module}/templates/vm-control.yml.tpl")}"
  vars = {
    ssh_user = var.vms_ssh_user
    ssh_root_key = var.vms_ssh_root_key
  }
}

## VM-CONTROL
resource "yandex_compute_instance" "vm_control" {
  count = var.vm_control_enable == true ? 1 : 0

  name        = "${var.vm_control_name}-${count.index + 1}"
  hostname    = "${var.vm_control_name}-${count.index + 1}"
  platform_id = var.vms_resources["control"].platform_id
  zone        = var.vm_control_zone
  resources {
    cores         = var.vms_resources["control"].cores
    memory        = var.vms_resources["control"].memory
    core_fraction = var.vms_resources["control"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_boot.0.id
      size     = var.vms_resources["control"].hdd_size
      type     = var.vms_resources["control"].hdd_type
    }
  }
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }

  scheduling_policy {
    preemptible = var.vms_resources["control"].preemptible
  }

  network_interface {
    subnet_id = var.vm_control_subnet_id
    nat       = var.vms_resources["control"].enable_nat
  }

  #metadata = local.vms_metadata_public_image

  metadata    = {
    #user-data = "${file("${path.module}/cloud-init/vm-control.yml")}"
    "user-data" = "${data.template_file.cloud_init.rendered}"
  }
  #depends_on = [ local_file.cloud_init_file ]
}

## Ожидание завершения cloud-init
resource "terraform_data" "cloud_init_wait" {
  count = var.vm_control_enable == true ? 1 : 0

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.vm_control[0].network_interface[0].nat_ip_address
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
}



## Копирование файлов на VM-CONTROLLER
resource "terraform_data" "ssh_config" {
  count = var.vm_control_enable == true ? 1 : 0

  ## Копирование файла приватного ключа для SSH
  provisioner "file" {
    source      = "${var.ssh_private_key_path}/${var.ssh_private_key_file}"
    destination = "./.ssh/${var.ssh_private_key_file}"
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.vm_control[0].network_interface[0].nat_ip_address
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }

  ## Меняем права доступа к файлу ключа
  ## (так требует сам ssh)
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo chmod 600 ~/.ssh/${var.ssh_private_key_file}"
    ]
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.vm_control[0].network_interface[0].nat_ip_address
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
  depends_on = [ terraform_data.cloud_init_wait ]
}
