#######################################
# МОДУЛЬ СОЗДАНИЯ СЕТЕВОЙ ИНФРАСТРУКТУРЫ
#######################################
module "net" {
  source = "./network-infrastructure"

  # Переменные модуля

  ## Каталог облака
  folder_id = var.folder_id

  ## Имя сети
  vpc_name = var.vpc_name

  ## Количество зон
  ## (default - 1)
  vpc_zones_count = var.vpc_zones_count # 3

  ## Названия зон (количество должно совпадать с vpc_zones_count)
  ## (default - ["ru-central1-a"])
  vpc_zones = var.vpc_zones

  ## Адреса Public-подсетей в привязке к зонам
  ## (в каждой зоне должно быть не менее одной сети)
  ## (default - [{zone: "ru-central1-a", cidr: ["10.1.1.0/24"]}])
  subnet_public_cidr = var.subnet_public_cidr

  ## Адреса Private-подсетей в привязке к зонам
  ## (в каждой зоне должно быть не менее одной сети)
  ## (default - [{zone: "ru-central1-a", cidr: ["192.168.1.0/24"]}])
  subnet_private_cidr = var.subnet_private_cidr

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
  vm_master_subnets = [for s in module.net.private : { id = s.id, zone = s.zone }]

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

  ## Enable SSH Forward for VM Masters via NAT-instances
  ## (default - false)
  ssh_master_forward_enable = true

  ## VM NAT-INSTANCES info (uses in making ssh forwarding, 
  ## gets from module 'network-infrustructure')
  vm_nat = module.net.vm_nat_zone

  ## External SSH PORT for VM Masters (start from)
  ## (default - 22000)
  ssh_nat_port = var.vms_ssh_nat_port

  ## ssh user
  ## (default - 'user')
  vms_ssh_user = var.vms_ssh_user

  ## ssh root-key
  vms_ssh_root_key = var.vms_ssh_root_key

  ## ssh private key path
  ## (default - './.ssh')
  ssh_private_key_path = var.ssh_private_key_path

  ## ssh private key filename
  ## (default - 'id_rsa')
  ssh_private_key_file = var.ssh_private_key_file

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

  ## ssh user
  ## (default - 'user')
  vms_ssh_user = var.vms_ssh_user

  ## ssh root-key
  vms_ssh_root_key = var.vms_ssh_root_key

  ## ssh private key path
  ## (default - './.ssh')
  ssh_private_key_path = var.ssh_private_key_path

  ## ssh private key filename
  ## (default - 'id_rsa')
  ssh_private_key_file = var.ssh_private_key_file

  depends_on = [module.cluster-infrastructure]
}

#######################################
# МОДУЛЬ УСТАНОВКИ NGINX
#######################################
module "nginx-deploy" {
  source = "./nginx"

  # Переменные модуля

  ## Master SSH Connect Data list
  master_ssh = module.cluster-infrastructure.master_ssh


  ## HTTP-порт функционирования NGINX
  ## (default - 80)
  nginx_port = var.nginx_port #8080

  ## ssh user
  ## (default - 'user')
  vms_ssh_user = var.vms_ssh_user

  ## ssh root-key
  vms_ssh_root_key = var.vms_ssh_root_key

  ## ssh private key path
  ## (default - './.ssh')
  ssh_private_key_path = var.ssh_private_key_path

  ## ssh private key filename
  ## (default - 'id_rsa')
  ssh_private_key_file = var.ssh_private_key_file


  depends_on = [module.cluster-infrastructure]
}

#######################################
# МОДУЛЬ БАЛАНСИРОВЩИКА НАГРУЗКИ 
# YANDEX NETWORK LOAD BALANCER
#######################################
module "kube-nlb" {
  source = "./network-load-balancer"

  # Переменные модуля

  ## Имя балансировщика
  ## (default - 'nlb')
  nlb_name = "kube-nlb"

  ## Создаем внешний IP-адрес
  ## (default - true)
  enable_public_ip = true

  ## Новый внешний IP (null)
  ## ИЛИ сами задаём
  ## (default - NULL)
  #public_ip = ""

  ## Public IP Zone
  ## (default - 'ru-central1-a')
  public_ip_zone = "ru-central1-a"

  ## IP protocol family {"ipv4"|"ipv6"} 
  ## (default - 'ipv4')
  #ip_version = "ipv4"

  ## NLB External Port for listenning
  nlb_ext_port = 8888

  ## Inner Port for check group
  nlb_int_port = 6443

  ## Heakthcheck Port for check group
  nlb_healthcheck_port = var.loadbalancer_healthcheck_port

  ## Servers healthcheck URL
  ## (default - '/')
  nlb_healthcheck_url = "/api"

  ## VM Master Data list 
  ##(list(object({fqdn,id,name,ip,nat_ip,zone,network_id
  vm_master = module.cluster-infrastructure.vm_master

  depends_on = [module.cluster-infrastructure]
}



#######################################
# МОДУЛЬ УСТАНОВКИ KUBERNETES
#######################################
module "kubernetes-deploy" {
  source = "./kubernetes-deploy"

  # Переменные модуля

  ## VM-CONTROL IP-address
  vm_control_ip = module.vm-control.vm_control[0].network_interface[0].nat_ip_address

  ## Cluster name
  ## (default - 'cluster.local')
  cluster_name = "cluster.local"

  ## Kubespray Ansible inventory relative path and file
  ## (default - './hosts.yml')
  ansible_host_file = var.ansible_host_file # "../ansible/hosts.yml"

  ## Kubernetes internal network for services
  ## (default - '10.233.0.0/18')
  kube_service_addresses = var.kube_service_addresses

  ## internal network. When used, it will assign IP
  ## addresses from this range to individual pods.
  ## (default - '10.233.64.0/18')
  kube_pods_subnet = var.kube_pods_subnet

  ## Core DNS IP
  ## (must be from kube_service_address network)
  ## (default - '10.233.0.2')
  coredns_ip = var.coredns_ip

  ## Virtual IP-address of external Load Balancer
  loadbalancer_ext_ip = module.kube-nlb.nlb_info.address #var.loadbalancer_ext_ip

  app_loadbalancer_ext_ip = null

  ## Virtual Port of external Load Balancer
  ## (default - 8888)
  loadbalancer_ext_port = var.loadbalancer_ext_port

  ## Inner Port of Load Balancer - port of apiserver
  ## (default - 6443)
  loadbalancer_int_port = var.loadbalancer_int_port

  ## enables proxy liveness check for nginx
  ## (default - 8081)
  loadbalancer_healthcheck_port = var.loadbalancer_healthcheck_port

  ## Port for metric server
  ## (default - 10000)
  metrics_server_container_port = var.metrics_server_container_port

  ## Master SSH Connect Data list
  master_ssh = module.cluster-infrastructure.master_ssh

  ## ssh user
  ## (default - 'user')
  vms_ssh_user = var.vms_ssh_user

  ## ssh root-key
  vms_ssh_root_key = var.vms_ssh_root_key

  ## ssh private key path
  ## (default - './.ssh')
  ssh_private_key_path = var.ssh_private_key_path

  ## ssh private key filename
  ## (default - 'id_rsa')
  ssh_private_key_file = var.ssh_private_key_file

  depends_on = [
    module.vm-control,
    module.cluster-infrastructure,
  ]
}


#######################################
# МОДУЛЬ БАЛАНСИРОВЩИКА НАГРУЗКИ 
# YANDEX APPICATION LOAD BALANCER
#######################################
module "kube-alb" {
  source = "./app-load-balancer"

  # Переменные модуля

  ## Имя балансировщика
  ## (default - 'alb')
  app_balancer_name = "kube-alb"

  ## VM Master Data list 
  ##(list(object({fqdn,id,name,ip,nat_ip,zone,network_id
  vm_master = module.cluster-infrastructure.vm_master

  ## VPC Network ID
  vpc_network_id = module.net.net.id

  ## List of Public subnets data
  vpc_public_subnets = module.net.public

  public_ip = module.kube-nlb.public_ip.external_ipv4_address[0].address

  ## ALB External Ports for listenning (list)
  ## (default - [80])
  app_balancer_ports = concat(
    var.app_balancer_ports,
    [{ from = var.nginx_port, to = var.nginx_port }],
    #[for s in range(11001, 11101): s]
  )

  ## Servers healthcheck URL
  app_balancer_healthcheck_url = var.app_balancer_healthcheck_url

  ## Servers healthcheck Port
  app_balancer_healthcheck_port = var.app_balancer_healthcheck_port

  depends_on = [
    module.cluster-infrastructure,
    module.kubernetes-deploy
  ]
}