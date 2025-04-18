#######################################
# Yandex.cloud SECRET VARS
#######################################
## cloud id
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
  sensitive   = true
}
## cloud-folder id
variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  sensitive   = true
}

#######################################
# Yandex.cloud DEFAULTS
#######################################
## Number of zones
variable "vpc_zones_count" {
  type        = number
  description = "Number of zones for cluster"
  #default     = 1
}
## List of zones
variable "vpc_zones" {
  type        = list(string)
  description = "List of zones (count must be equal to 'var.vpc_zones_count')"
  #default     = ["ru-central1-a"]
}

#######################################
# Yandex.cloud NETWORK VARS
#######################################
## default network name
variable "vpc_name" {
  type        = string
  description = "VPC network"
  #default     = "develop"
}
## default PUBLIC net name
variable "subnet_public_name" {
  type        = string
  description = "VPC public subnet name"
  #default     = "public"
}
## default PUBLIC net cidr
variable "subnet_public_cidr" {
  type = list(object({
    zone : string,
    cidr : list(string)
  }))
  description = "VPC public cidr (count must be equal to 'var.vpc_zones_count') (https://cloud.yandex.ru/docs/vpc/operations/subnet-create)"
  #default     = [{ zone : "ru-central1-a", cidr : ["10.1.1.0/24"] }]
}
## default PRIVATE net name
variable "subnet_private_name" {
  type        = string
  description = "VPC private subnet name"
  #default     = "private"
}
## default PRIVATE net cidr
variable "subnet_private_cidr" {
  type = list(object({
    zone : string,
    cidr : list(string)
  }))
  description = "VPC private cidr (count must be equal to 'var.vpc_zones_count') (https://cloud.yandex.ru/docs/vpc/operations/subnet-create)"
  #default     = [{ zone : "ru-central1-a", cidr : ["192.168.1.0/24"] }]
}

#######################################
# KUBERNETES CONFIG VARS
#######################################
## Kubespray Ansible inventory relative path and file
variable "ansible_host_file" {
  type        = string
  description = "Ansible inventory relative path and file"
}

## Kubernetes internal network for services, unused block of space
variable "kube_service_addresses" {
  type        = string
  description = "Kubernetes internal network for services"
  #default     = "10.233.0.0/18"
}
## internal network. When used, it will assign IP
## addresses from this range to individual pods.
variable "kube_pods_subnet" {
  type        = string
  description = "internal network. When used, it will assign IP-addresses from this range to individual pods. This network must be unused in your network infrastructure!"
  #default     = "10.233.64.0/18"
}
## Core DNS IP
## (must be from kube_service_address network)
## (default - '10.233.0.2')
variable "coredns_ip" {
  type        = string
  description = "Core DNS IP (must be from kube_service_address network)"
  #default     = "10.233.0.2"
}

## Virtual IP for check group
variable "loadbalancer_ext_ip" {
  type        = string
  description = "Virtual IP for check group"
  default     = null
}
## Virtual Port for check group
variable "loadbalancer_ext_port" {
  type        = number
  description = "Virtual Port for check group (default - 8888)"
  #default     = 8888
}
## Inner Port for check group
variable "loadbalancer_int_port" {
  type        = number
  description = "Inner Port for check group (default - 6443)"
  #default     = 6443
}
## Proxy liveness healthcheck port (for nginx)
variable "loadbalancer_healthcheck_port" {
  type        = number
  description = "Proxy liveness healthcheck port (for nginx)"
  #default     = 8081
}
## Port for metric server
variable "metrics_server_container_port" {
  type        = number
  description = "Port for metric server"
  #default     = 10000
}
#######################################
# YANDEX APPLICATION LOAD BALANCER (ALB)
#######################################
## ALB External Ports for listenning (list)
variable "app_balancer_ports" {
  type        = list(number)
  description = "ALB External Ports for listenning (list(number))"
  #default = [80]
}

## ALB healthcheck Port
variable "app_balancer_healthcheck_port" {
  type        = string
  description = "ALB healthcheck Port"
}
## ALB healthcheck URL
variable "app_balancer_healthcheck_url" {
  type        = string
  description = "ALB healthcheck URL"
  #default = "/healthz"
}



## HTTP-порт функционирования NGINX
## (default - 80)
variable "nginx_port" {
  type        = number
  description = "HTTP-порт функционирования NGINX (default - 80)"
  #default = 80
}

#######################################
# VMs RESOURCES
#######################################
## VMs resources
variable "vms_resources" {
  type = map(object({
    platform_id : string,
    cores : number,
    memory : number,
    core_fraction : number,
    preemptible : bool,
    hdd_size : number,
    hdd_type : string,
    enable_nat : bool,
    ip_address : string,
  }))
  description = "{platform_id=<STRING>, cores=<NUMBER>, memory=<NUMBER>, core_fraction=<NUMBER>, vm_db_preemptible: <BOOL>, hdd_size=<NUMBER>, hdd_type=<STRING>, enable_nat: <BOOL>}"
}


#######################################
# SSH vars
#######################################
## ssh user
variable "vms_ssh_user" {
  type        = string
  description = "SSH user"
  #default     = "user"
}
## ssh nat port for connecting via nat-instance
variable "vms_ssh_nat_port" {
  type        = number
  description = "ssh nat port for connecting via nat-instance (default - 22000)"
  #default     = 22000
}
## ssh root-key
variable "vms_ssh_root_key" {
  type        = string
  description = "ssh-keygen -t ed25519"
}
## ssh private key path
## (without last '/')
variable "ssh_private_key_path" {
  type        = string
  description = "## ssh private key path (without last '/') (default - './.ssh')"
  #default     = "./.ssh"
}
## ssh private key filename
variable "ssh_private_key_file" {
  type        = string
  description = "## ssh private key filename (default - 'id_rsa')"
  #default     = "id_rsa"
}
