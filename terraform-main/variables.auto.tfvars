#######################################
# Yandex.cloud DEFAULTS
#######################################
vpc_zones       = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]

#######################################
# Yandex.cloud NETWORK VARS
#######################################
vpc_name            = "diplom"
subnets_name = {
  "public": "public",
  "private": "private"
}
subnets_data = {
  "public" = [
    {
      zone : "ru-central1-a",
      cidr : ["10.1.1.0/24"]
    }, {
      zone : "ru-central1-b",
      cidr : ["10.1.2.0/24"]
    }, {
      zone : "ru-central1-d",
      cidr : ["10.1.3.0/24"]
    }
  ],
  "private" = [
    {
      zone : "ru-central1-a",
      cidr : ["192.168.101.0/24", "192.168.200.0/24"],
    }, {
      zone : "ru-central1-b",
      cidr : ["192.168.102.0/24"],
    }, {
      zone : "ru-central1-d",
      cidr : ["192.168.103.0/24"],
    }
  ]
}

#######################################
# VM-CONTROL VARS
#######################################
## VM-CONTROL name
vm_control_enable = true
vm_control_name = "vm-control"
vm_control_zone = "ru-central1-a"
vm_control_os_family = "ubuntu-2404-lts-oslogin"

#######################################
# KUBERNETES CONFIG VARS
#######################################
ansible_host_file      = "../ansible/hosts.yml"
kube_service_addresses = "10.233.0.0/18"
kube_pods_subnet       = "10.233.64.0/18"
coredns_ip             = "10.233.0.10"

loadbalancer_ext_port         = 8888
loadbalancer_int_port         = 6443
loadbalancer_healthcheck_port = 6443 #8081
metrics_server_container_port = 9999 #4443

#######################################
# NGINX CONFIG VARS
#######################################
nginx_port = 8080

#######################################
# YANDEX APPLICATION LOAD BALANCER (ALB)
#######################################
app_balancer_ports = [
  { from = 3000, to = 3000 },
  { from = 9000, to = 31111 },
  { from = 10100, to = 31100 },  #9100
  { from = 9090, to = 31090 },
  { from = 9099, to = 31099 },
  { from = 80, to = 31000 },
]
app_balancer_healthcheck_port = 8080
app_balancer_healthcheck_url  = "/" #"/healthz"

#######################################
# CONTAINER REGISTRY
#######################################
registry_name = "devops-registry"

#######################################
# GENERAL SSH VARS
#######################################
vms_ssh_user         = "user"
vms_ssh_nat_port     = 22000
ssh_private_key_path = "../keys"
ssh_private_key_file = "id_ed25519"

#######################################
# GENERAL VMs RESOURCES
#######################################
vms_resources = {
  "master" = {
    platform_id   = "standard-v3"
    cores         = 2
    memory        = 2
    core_fraction = 20
    preemptible   = true
    hdd_size      = 50
    hdd_type      = "network-hdd"
    enable_nat    = false,
    ip_address    = ""
  },
  "worker" = {
    platform_id   = "standard-v3"
    cores         = 2
    memory        = 2
    core_fraction = 20
    preemptible   = true
    hdd_size      = 50
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
  "control" = {
    platform_id   = "standard-v3"
    cores         = 2
    memory        = 2
    core_fraction = 20
    preemptible   = true
    hdd_size      = 30
    hdd_type      = "network-hdd"
    enable_nat    = true
    ip_address    = ""
  },
}