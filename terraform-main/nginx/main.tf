#######################################
# УСТАНОВКА NGINX НА VM MASTER-Ы
#######################################
## Установка nginx
resource "terraform_data" "nginx_install" {
  count = local.master_count

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo apt update", # maybe conflict in onetime execution with keepalived or other modules
      "sudo apt install -y nginx",
      "sudo chown -R ${var.vms_ssh_user} /etc/nginx",
      "sudo chown -R ${var.vms_ssh_user} /var/www/html",
    ]
    connection {
      type        = "ssh"
      host        = var.master_ssh[count.index].nat_ip
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
      port        = var.master_ssh[count.index].nat_port
    }
  }
}

## Создание тестовой html-страницы
resource "local_file" "nginx_index_html" {
  count = local.master_count

  content = templatefile("${path.module}/templates/index.html.tpl",
    {
      server_name = var.master_ssh[count.index].name
      server_ip   = var.master_ssh[count.index].ip
    }
  )
  filename = "${path.module}/nginx/index-${count.index}.html"
  # зависимости
  depends_on = [terraform_data.nginx_install]
}

## Создание конфигурации NGINX
resource "local_file" "nginx_config" {
  content = templatefile("${path.module}/templates/default-conf.tpl",
    {
      server_port = var.nginx_port
    }
  )
  filename = "${path.module}/nginx/default"
  # зависимости
  depends_on = [terraform_data.nginx_install]
}



## Копирование тестовой html-страницы
## и файла настроек
resource "terraform_data" "nginx_copy_index_html223" {
  count = local.master_count
  ## Копирование в файл '/var/www/html/index.html'
  ## созданного ранее из шаблона
  provisioner "file" {
    source      = "${path.module}/nginx/index-${count.index}.html"
    destination = "/var/www/html/index.html"
    connection {
      type        = "ssh"
      host        = var.master_ssh[count.index].nat_ip
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
      port        = var.master_ssh[count.index].nat_port
    }
  }
  provisioner "file" {
    source      = "${path.module}/nginx/default"
    destination = "/etc/nginx/sites-available/default"
    connection {
      type        = "ssh"
      host        = var.master_ssh[count.index].nat_ip
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
      port        = var.master_ssh[count.index].nat_port
    }
  }

  depends_on = [
    local_file.nginx_index_html,
    local_file.nginx_config,
  ]
}

## Запуск службы с новыми параметрами
resource "terraform_data" "nginx_start223" {
  count = local.master_count

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo systemctl enable nginx",
      "sudo systemctl restart nginx",
    ]
    connection {
      type        = "ssh"
      host        = var.master_ssh[count.index].nat_ip
      user        = var.vms_ssh_user
      private_key = file("${var.ssh_private_key_path}/${var.ssh_private_key_file}")
      port        = var.master_ssh[count.index].nat_port
    }
  }
  depends_on = [terraform_data.nginx_copy_index_html223]
}
