#######################################
# УСТАНОВКА ТРЕБУЕМОГО ПО НА VM-CONTROL
#######################################
## Установка зависимостей для Kubespray
resource "terraform_data" "prepare_for_install_kubespray224" {
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
resource "local_file" "kubespray_config_file_cluster224" {
  content = templatefile("${path.module}/templates/k8s-cluster.yml.tpl",
    {
      cluster_name           = var.cluster_name           #"cluster.local"
      kube_service_addresses = var.kube_service_addresses #"10.233.0.0/18"
      kube_pods_subnet       = var.kube_pods_subnet       #"10.233.64.0/18"
      coredns_ip             = var.coredns_ip             #"10.233.0.10"
      kube_apiserver_port    = var.loadbalancer_int_port  #6443
      loadbalancer_ext_ip    = var.loadbalancer_ext_ip
    }
  )
  filename = "${path.module}/kubespray/k8s-cluster.yml"
  # зависимости
  depends_on = [terraform_data.prepare_for_install_kubespray224]
}

## Создание конфигурационных файлов из шаблонов - all.yml
resource "local_file" "kubespray_config_file_general224" {
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
  depends_on = [terraform_data.prepare_for_install_kubespray224]
}

## Создание конфигурационных файлов из шаблонов - addons.yml
resource "local_file" "kubespray_config_file_addons224" {
  content = templatefile("${path.module}/templates/addons.yml.tpl",
    {
      loadbalancer_ext_ip = var.loadbalancer_ext_ip
    }
  )
  filename = "${path.module}/kubespray/addons.yml"
  # зависимости
  depends_on = [terraform_data.prepare_for_install_kubespray224]
}

#######################################
# КОПИРОВАНИЕ ФАЙЛ НАСТРОЕК
#######################################
## Копирование HOSTS.yml
resource "terraform_data" "kubespray_load_hosts224" {
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
  depends_on = [terraform_data.prepare_for_install_kubespray224]
}

## Копирование файлов из шаблонов
resource "terraform_data" "kubespray_load_config224" {
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
    local_file.kubespray_config_file_cluster224,
    local_file.kubespray_config_file_general224,
    local_file.kubespray_config_file_addons224,
  ]
}

#######################################
# УСТАНОВКА KUBERNETES
#######################################
## Установка Kubernetes
resource "terraform_data" "kubespray_install_kubernetes" {
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
    terraform_data.kubespray_load_hosts224,
    terraform_data.kubespray_load_config224,
  ]
}

#######################################
# КОПИРОВАНИЕ КОНФИГУРАЦИОННОГО ФАЙЛА
# KUBERNETES
#######################################
## Копирование файла /etc/kubernetes/admin.cfg
## с любого мастера (Master-1)
resource "terraform_data" "kubernetes_copy_config" {
  provisioner "local-exec" {
    command = "sudo scp -i ${file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")} -P ${var.master_ssh[0].nat_port} ${var.vms_ssh_user}@${var.master_ssh[0].nat_ip}:/etc/kubernetes/admin/cfg ../config"
  }

  depends_on = [terraform_data.kubespray_install_kubernetes]
}
