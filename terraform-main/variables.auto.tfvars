#######################################
# Yandex.cloud DEFAULTS
#######################################
vpc_zones_count = 3
vpc_zones       = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]

#######################################
# Yandex.cloud NETWORK VARS
#######################################
vpc_name            = "diplom"
subnet_public_name  = "public"
subnet_private_name = "private"
subnet_public_cidr = [
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
]
subnet_private_cidr = [
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
  { from = 9000, to = 9000 },
  { from = 9001, to = 9001 },
  { from = 9090, to = 9090 },
  { from = 10000, to = 10000 },
  { from = 80, to = 30238 }
]
app_balancer_healthcheck_port = 8080
app_balancer_healthcheck_url  = "/" #"/healthz"

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