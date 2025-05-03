#######################################
# УСТАНОВКА ТРЕБУЕМОГО ПО НА VM-CONTROL
#######################################
## Установка зависимостей для Kubespray
resource "terraform_data" "prepare_for_install_kubespray" {
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
      host        = var.vm_control_ip
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
}

#######################################
# СОЗДАНИЕ ФАЙЛОВ НАСТРОЕК ИЗ ШАБЛОНОВ
#######################################
## Создание конфигурационных файлов из шаблонов - k8s-cluster.yml
resource "local_file" "kubespray_config_file_cluster227" {
  content = templatefile("${path.module}/templates/k8s-cluster.yml.tpl",
    {
      cluster_name            = var.cluster_name           #"cluster.local"
      kube_service_addresses  = var.kube_service_addresses #"10.233.0.0/18"
      kube_pods_subnet        = var.kube_pods_subnet       #"10.233.64.0/18"
      coredns_ip              = var.coredns_ip             #"10.233.0.10"
      kube_apiserver_port     = var.loadbalancer_int_port  #6443
      loadbalancer_ext_ip     = var.loadbalancer_ext_ip
      app_loadbalancer_ext_ip = var.app_loadbalancer_ext_ip != null ? var.app_loadbalancer_ext_ip : "10.0.0.1"
    }
  )
  filename = "${path.module}/kubespray/k8s-cluster.yml"
  # зависимости
  depends_on = [terraform_data.prepare_for_install_kubespray]
}

## Создание конфигурационных файлов из шаблонов - all.yml
resource "local_file" "kubespray_config_file_general227" {
  content = templatefile("${path.module}/templates/all.yml.tpl",
    {
      loadbalancer_ext_ip           = var.loadbalancer_ext_ip
      loadbalancer_ext_port         = var.loadbalancer_ext_port
      loadbalancer_int_port         = var.loadbalancer_int_port
      loadbalancer_healthcheck_port = var.loadbalancer_healthcheck_port
    }
  )
  filename = "${path.module}/kubespray/all.yml"
  # зависимости
  depends_on = [terraform_data.prepare_for_install_kubespray]
}

## Создание конфигурационных файлов из шаблонов - addons.yml
resource "local_file" "kubespray_config_file_addons227" {
  content = templatefile("${path.module}/templates/addons.yml.tpl",
    {
      loadbalancer_ext_ip           = var.loadbalancer_ext_ip
      metrics_server_container_port = var.metrics_server_container_port
    }
  )
  filename = "${path.module}/kubespray/addons.yml"
  # зависимости
  depends_on = [terraform_data.prepare_for_install_kubespray]
}

#######################################
# КОПИРОВАНИЕ ФАЙЛ НАСТРОЕК
#######################################
## Копирование HOSTS.yml
resource "terraform_data" "kubespray_load_hosts227" {
  ## Копирование файла hosts.yml,
  ## созданного автоматически модулем 'cluster-infrastructure'
  provisioner "file" {
    source      = var.ansible_host_file
    destination = "kubespray/inventory/sample/hosts.yml"
    connection {
      type        = "ssh"
      host        = var.vm_control_ip
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
  depends_on = [terraform_data.prepare_for_install_kubespray]
}

## Копирование файлов из шаблонов
resource "terraform_data" "kubespray_load_config227" {
  ## Копирование файла k8s-cluster.yml
  provisioner "file" {
    source      = "${path.module}/kubespray/k8s-cluster.yml"
    destination = "kubespray/inventory/sample/group_vars/k8s_cluster/k8s-cluster.yml"
    connection {
      type        = "ssh"
      host        = var.vm_control_ip
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
  ## Копирование файла all.yml
  provisioner "file" {
    source      = "${path.module}/kubespray/all.yml"
    destination = "kubespray/inventory/sample/group_vars/all/all.yml"
    connection {
      type        = "ssh"
      host        = var.vm_control_ip
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
  ## Копирование файла addons.yml
  provisioner "file" {
    source      = "${path.module}/kubespray/addons.yml"
    destination = "kubespray/inventory/sample/group_vars/k8s_cluster/addons.yml"
    connection {
      type        = "ssh"
      host        = var.vm_control_ip
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
  depends_on = [
    local_file.kubespray_config_file_cluster227,
    local_file.kubespray_config_file_general227,
    local_file.kubespray_config_file_addons227,
  ]
}

#######################################
# УСТАНОВКА KUBERNETES
#######################################
## Установка Kubernetes
resource "terraform_data" "kubespray_install_kubernetes227" {
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "python3 -m venv kubespray-venv",
      "source kubespray-venv/bin/activate",
      "cd kubespray",
      "ansible-playbook -i inventory/sample/hosts.yml --private-key=~/.ssh/${var.ssh_private_key_file} -u ${var.vms_ssh_user} -b -v cluster.yml"
    ]
    connection {
      type        = "ssh"
      host        = var.vm_control_ip
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
    }
  }
  depends_on = [
    terraform_data.kubespray_load_hosts227,
    terraform_data.kubespray_load_config227,
  ]
}

#######################################
# КОПИРОВАНИЕ КОНФИГУРАЦИОННОГО ФАЙЛА
# KUBERNETES
#######################################
## Копирование файла /etc/kubernetes/admin.conf в /temp/config
## с любого мастера (Master-1)
resource "terraform_data" "kubernetes_copy_config227" {
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo cp /etc/kubernetes/admin.conf /tmp/config",
      "sudo chown ${var.vms_ssh_user} /tmp/config",
    ]
    connection {
      type        = "ssh"
      host        = var.master_ssh[0].nat_ip
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
      port        = var.master_ssh[0].nat_port
    }
  }
  depends_on = [terraform_data.kubespray_install_kubernetes227]
}

## Копирование файла /tmp/config
## с Master-1
resource "terraform_data" "kubernetes_copy_config_local227" {
  provisioner "local-exec" {
    # command = "scp -o 'StrictHostKeyChecking=no' -i ${var.ssh_private_key_path}/${var.ssh_private_key_file} -P ${var.master_ssh[0].nat_port} ${var.vms_ssh_user}@${var.master_ssh[0].nat_ip}:/etc/kubernetes/admin.conf ~/.kube/"
    command = "mkdir -p ~/.kube && scp -o 'StrictHostKeyChecking=no' -P ${var.master_ssh[0].nat_port} ${var.vms_ssh_user}@${var.master_ssh[0].nat_ip}:/tmp/config ~/.kube/"
  }

  depends_on = [terraform_data.kubernetes_copy_config227]
}
