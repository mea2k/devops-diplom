#######################################
# МОДУЛЬ СОЗДАНИЯ СЕТЕВОЙ ИНФРАСТРУКТУРЫ
#######################################
module "net" {
  source = "./network-infrastructure"

  # Переменные модуля

  ## Каталог облака
  folder_id = var.folder_id

  ## Имя сети
  vpc_name = "diplom"

  ## Количество зон
  ## (default - 1)
  vpc_zones_count = 3

  ## Названия зон (количество должно совпадать с vpc_zones_count)
  ## (default - ["ru-central1-a"])
  vpc_zones = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]

  ## Адреса Public-подсетей (количество должно совпадать с vpc_zones_count)
  ## (default - ["10.1.1.0/24"])
  subnet_public_cidr = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]

  ## Адреса Private-подсетей (количество должно совпадать с vpc_zones_count)
  ## (default - ["192.168.1.0/24"])
  subnet_private_cidr = ["192.168.101.0/24", "192.168.102.0/24", "192.168.103.0/24"]

  ## Имя статической таблицы маршрутизации
  ## (default - 'nat-instance-route')
  route_table_name = "nat-route"

  ## Создание NAT-instance для PRIVATE-подсетей
  ## (подразумевает сождание отдельной ВМ)
  ## (default - TRUE)
  vm_nat_enable = true

  ## Имя ВМ Nat-instance
  ## (default - 'nat')
  vm_nat_name = "nat"

  ## VM NAT OS family 
  ## (default - 'nat-instance-ubuntu')
  vm_nat_os_family = "nat-instance-ubuntu"

  ## VMs resources
  ## using default
  vms_resources = var.vms_resources

  ## ssh user
  ## (default - 'user')
  vms_ssh_user = var.vms_ssh_user

  ## ssh root-key
  vms_ssh_root_key = var.vms_ssh_root_key
}

#######################################
# МОДУЛЬ СОЗДАНИЯ ИНФРАСТРУКТУРЫ ДЛЯ КЛАСТЕРА
#######################################
module "cluster-infrastructure" {
  source = "./cluster-infrastructure"

  # Переменные модуля

  ## VM Master name
  ## (default - 'master')
  vm_master_name = "master"

  ## Number of Masters
  ## (default - 3)
  vm_master_count = 3

  ## List of Master subnets Ids
  ## (count must be equal to 'var.vm_master_count')
  vm_master_subnets = [for s in module.net.public : { id = s.id, zone = s.zone }]

  ## VM Worker name
  ## (default - 'woker')
  vm_worker_name = "worker"

  ## Number of Workers
  ## (default - 2)
  vm_worker_count = 4

  ## List of Worker subnets Ids
  ## (count must be equal to 'var.vm_worker_count')
  vm_worker_subnets = concat(
    [{ id = module.net.private[0].id, zone = module.net.private[0].zone }],
    [for s in module.net.private : { id = s.id, zone = s.zone }]
  )

  ## VMs resources - use default
  vms_resources = var.vms_resources

  ## VM Cluster nodes OS Image family
  ## (default - ubuntu-2404-lts-oslogin)
  vms_os_family = "ubuntu-2404-lts-oslogin"

  ## Ansible inventory relative path
  ## (default - './')
  ansible_inventory_path = "../ansible/"

  ## ssh user
  ## (default - 'user')
  vms_ssh_user = var.vms_ssh_user

  ## ssh root-key
  vms_ssh_root_key = var.vms_ssh_root_key

  # запуск после создания сетей (module.net)
  depends_on = [module.net]
}

#######################################
# МОДУЛЬ СОЗДАНИЯ ВМ ДЛЯ УПРАВЛЕНИЯ
# УСТАНОВКОЙ KUBERNETES
# (данная ВМ имеет доступ ко всем узлам)
#######################################
module "vm-control" {
  source = "./vm-control"

  # Переменные модуля

  ## Включение создания VM-CONTROL
  ## (default - true)
  vm_control_enable = true

  ## VM-CONTROL name
  ## (default - 'vm-control')
  vm_control_name = "vm-control"

  ## VM-CONTROl zone
  ## (default - 'ru-central1-a')
  vm_control_zone = "ru-central1-a"

  ## VM-CONTROL subnet ID
  vm_control_subnet_id = module.net.public[0].id

  ## VM-CONTROL OS family (used in yandex_compute_image)
  ## (default - 'ubuntu-2404-lts-oslogin')
  vm_control_os_family = "ubuntu-2404-lts-oslogin"

  ## VMs resources - use default
  vms_resources = var.vms_resources

  ## Kubespray Ansible inventory relative path
  ## (default - './hosts.yml')
  ansible_host_file = "../ansible/hosts.yml"

  ## ssh user
  ## (default - 'user')
  vms_ssh_user = var.vms_ssh_user

  ## ssh root-key
  vms_ssh_root_key = var.vms_ssh_root_key

  ## ssh private key path
  ## (default - './.ssh')
  ssh_private_key_path = "../keys"

  ## ssh private key filename
  ## (default - 'id_rsa')
  ssh_private_key_file = "id_ed25519"
}


