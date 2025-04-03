#######################################
# CLUSTER CONFIG
#######################################
## Number of Masters
variable "vm_master_count" {
  type        = number
  description = "Number of VM Master"
  default     = 3
}
## Number of Workers
variable "vm_worker_count" {
  type        = number
  description = "Number of VM Worker"
  default     = 2
}
## VM Master name
variable "vm_master_name" {
  type        = string
  description = "VM Master name"
  default     = "master"
}
## VM Worker name
variable "vm_worker_name" {
  type        = string
  description = "VM Worker name"
  default     = "worker"
}
## List of Master subnets Ids
variable "vm_master_subnets" {
  type        = list(object({
    id : string,
    zone : string
  }))
  description = "List of subnets Ids for VMs Master (count must be equal to 'var.vm_master_count')"
}
## List of Worker subnets Ids
variable "vm_worker_subnets" {
  type        = list(object({
    id : string,
    zone : string
  }))
  description = "List of subnets Ids for VMs Worker (count must be equal to 'var.vm_worker_count')"
}

#######################################
# CLUSTER NODES VARS
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
  default = {
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
}
## VM Cluster nodes OS Image family
variable "vms_os_family" {
  type        = string
  description = "OS family for Cluster VM Nodes ('yc compute image list --folder-id standard-images')"
  default     = "ubuntu-2404-lts-oslogin"
}

variable "vm_nat_os_family" {
  type        = string
  description = "OS family for NAT from Yandex.CLoud ('yc compute image list --folder-id standard-images')"
  default     = "nat-instance-ubuntu"
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
