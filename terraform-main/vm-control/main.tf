#######################################
# ВМ ДЛЯ УПРАВЛЕНИЯ РЕСУРСАМИ
#######################################
## Образ загрузочного диска
data "yandex_compute_image" "vm_boot" {
  count = var.vm_control_enable == true ? 1 : 0

  family = var.vm_control_os_family
}
## VM-ONTROL
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

  # metadata = {
  #   serial-port-enable = local.vms_metadata.serial_port_enable #1
  #   ssh-keys           = local.vms_metadata.ssh_keys[0]        #"ubuntu:${var.vms_ssh_root_key}"
  # }
  metadata = local.vms_metadata_public_image
}

#######################################
# УСТАНОВКА ТРЕБУЕМОГО ПО НА VM-CONTROL
#######################################
## Установка необходимых зависимостей
resource "terraform_data" "install_common" {
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt install -y software-properties-common",
      "sudo apt install -y git git-extras",
      "sudo apt install -y python3 python3-pip pipx",
    ]
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.vm_control[0].network_interface[0].nat_ip_address
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
}

## Установка ANSIBLE
resource "terraform_data" "install_ansible" {
  provisioner "remote-exec" {
    inline = [
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      #"sudo apt install -y ansible --reinstall ",  # will install during pip indtall -r requirements.txt
    ]
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.vm_control[0].network_interface[0].nat_ip_address
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
  depends_on = [terraform_data.install_common]
}

## Установка Kubectl
resource "terraform_data" "install_kubectl" {
  provisioner "remote-exec" {
    inline = [
      "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
      "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl"
    ]
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.vm_control[0].network_interface[0].nat_ip_address
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
  depends_on = [terraform_data.install_ansible]
}

## Установка Kubespray
resource "terraform_data" "install_kubespray" {
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "git-force-clone -b master https://github.com/kubernetes-incubator/kubespray.git kubespray",
      "python3 -m venv kubespray-venv",
      "source kubespray-venv/bin/activate",
      "cd kubespray",
      "pip install -U -r requirements.txt"
    ]
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.vm_control[0].network_interface[0].nat_ip_address
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
  depends_on = [terraform_data.install_ansible]
}

## Копирование файлов на VM-CONTROLLER
resource "terraform_data" "kubespray_config3" {
  ## Копирование файла hosts.yml,
  ## созданного автоматически модулем 'cluster-infrastructure'
  provisioner "file" {
    source      = var.ansible_host_file
    destination = "kubespray/inventory/hosts.yml"
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.vm_control[0].network_interface[0].nat_ip_address
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }

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

  depends_on = [terraform_data.install_kubespray]

}

## Установка Kubernetes
resource "terraform_data" "kubespray_install" {
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "python3 -m venv kubespray-venv",
      "source kubespray-venv/bin/activate",
      "cd kubespray",
      "ansible-playbook -i inventory/hosts.yml --private-key=~/.ssh/${var.ssh_private_key_file} -u ${var.vms_ssh_user} -b -v cluster.yml"
    ]
    connection {
      type        = "ssh"
      host        = yandex_compute_instance.vm_control[0].network_interface[0].nat_ip_address
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
  depends_on = [terraform_data.kubespray_config3]
}
