#######################################
# МОДУЛЬ СОЗДАНИЯ СЕТЕВОЙ ИНФРАСТРУКТУРЫ
#######################################
module "net" {
  source        = "./network-infsrastructure"

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
  vpc_zones       = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
  
  ## Адреса Public-подсетей (количество должно совпадать с vpc_zones_count)
  ## (default - ["10.1.1.0/24"])
  subnet_public_cidr  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  
  ## Адреса Private-подсетей (количество должно совпадать с vpc_zones_count)
  ## (default - ["192.168.1.0/24"])
  subnet_private_cidr = ["192.168.101.0/24", "192.168.102.0/24", "192.168.103.0/24"]
}

#######################################
# МОДУЛЬ СОЗДАНИЯ ИНФРАСТРУКТУРЫ ДЛЯ КЛАСТЕРА
#######################################
module "cluster-infrastructure" {
  source        = "./cluster-infrastructure"

  # Переменные модуля

  ## VM Master name
  ## (default - 'master')
  vm_master_name = "master"
  
  ## Number of Masters
  ## (default - 3)
  vm_master_count = 3
  
  ## List of Master subnets Ids
  ## (count must be equal to 'var.vm_master_count')
  vm_master_subnets =  [for s in module.net.public : {id=s.id, zone=s.zone}]
  
  ## VM Worker name
  ## (default - 'woker')
  vm_worker_name = "worker"
  
  ## Number of Workers
  ## (default - 2)
  vm_worker_count = 4
  
  ## List of Worker subnets Ids
  ## (count must be equal to 'var.vm_worker_count')
  vm_worker_subnets = concat([{id=module.net.private[0].id, zone=module.net.private[0].zone}], [for s in module.net.private : {id=s.id, zone=s.zone}])
  
  ## VMs resources - use default
  vms_resources = {
    "master" = {
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 2
      core_fraction = 20
      preemptible   = true
      hdd_size      = 30
      hdd_type      = "network-hdd"
      enable_nat    = true,
      ip_address    = ""
    },
    "worker" = {
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 1
      core_fraction = 20
      preemptible   = true
      hdd_size      = 20
      hdd_type      = "network-hdd"
      enable_nat    = false,
      ip_address    = ""
    },
    "nat" = {
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 1
      core_fraction = 20
      preemptible   = true
      hdd_size      = 10
      hdd_type      = "network-hdd"
      enable_nat    = true
      ip_address    = ""
    },
  }

  ## VM Cluster nodes OS Image family
  ## (default - ubuntu-2404-lts-oslogin)
  vms_os_family = "ubuntu-2404-lts-oslogin"
 
  ## ssh user
  ## (default - 'user')
  vms_ssh_user = "user"
 
  ## ssh root-key
  vms_ssh_root_key = var.vms_ssh_root_key

  # запуск после создания сетей (modele.net)
  depends_on = [ module.net ]
}




