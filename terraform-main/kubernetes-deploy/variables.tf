#######################################
# INFRASTRUCTURE VARS
#######################################
## Master SSH Connect Data list
variable "master_ssh" {
  type = list(object({
    name : string,
    ip : string,
    nat_ip : string,
    nat_port : number,
  }))
  description = "Master SSH Connect Data list (list(object({name, master_ip, nat_ip, nat_port}))"
}

#######################################
# VM-CONTROL VARS
#######################################
## VM-CONTROL IP-address
variable "vm_control_ip" {
  type        = string
  description = "IP-address of VM-CONTROL"
}

#######################################
# ANSIBLE VARS
#######################################
## Kubespray Ansible inventory relative path and file
variable "ansible_host_file" {
  type        = string
  description = "Ansible inventory relative path and file"
  default     = "./hosts.yml"
}

#######################################
# KUBERNETES CONFIG VARS
#######################################
## Cluster name
variable "cluster_name" {
  type        = string
  description = "Cluster name"
  default     = "cluster.local"
}
## Kubernetes internal network for services, unused block of space
variable "kube_service_addresses" {
  type        = string
  description = "Kubernetes internal network for services"
  default     = "10.233.0.0/18"
}
## internal network. When used, it will assign IP
## addresses from this range to individual pods.
variable "kube_pods_subnet" {
  type        = string
  description = "internal network. When used, it will assign IP-addresses from this range to individual pods. This network must be unused in your network infrastructure!"
  default     = "10.233.64.0/18"
}
## Core DNS IP
## (must be from kube_service_address network)
## (default - '10.233.0.2')
variable "coredns_ip" {
  type        = string
  description = "Core DNS IP (must be from kube_service_address network)"
  default     = "10.233.0.2"
}

## Public(external) IP-address of external Network Load Balancer
variable "loadbalancer_ext_ip" {
  type        = string
  description = "Virtual IP-address of external Network Load Balancer. Kubernetes cluster will be availabel on this IP outside"
}

## Public(external) IP-address of external Application Load Balancer
variable "app_loadbalancer_ext_ip" {
  type        = string
  description = "Virtual IP-address of external Application Load Balancer. Kubernetes cluster will be availabel on this IP outside"
}

## Virtual Port of external Load Balancer
variable "loadbalancer_ext_port" {
  type        = number
  description = "Virtual Port of external Load Balancer. Kubernetes cluster will be availabel on this IP"
  default     = 8888
}
## Internal Port of Load Balancer
## The same as kube_apiserver_port
variable "loadbalancer_int_port" {
  type        = number
  description = "Internal Port of Load Balancer. The same as kube_apiserver_port"
  default     = 6443
}
## Proxy liveness healthcheck port (for nginx)
variable "loadbalancer_healthcheck_port" {
  type        = number
  description = "Proxy liveness healthcheck port (for nginx)"
  default     = 8081
}
## Port for metric server
variable "metrics_server_container_port" {
  type        = number
  description = "Port for metric server"
  default     = 10000
}

#######################################
# SSH vars
#######################################
## ssh user
variable "vms_ssh_user" {
  type        = string
  description = "SSH user"
  default     = "user"
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
  default     = "./.ssh"
}
## ssh private key filename
variable "ssh_private_key_file" {
  type        = string
  description = "## ssh private key filename (default - 'id_rsa')"
  default     = "id_rsa"
}
