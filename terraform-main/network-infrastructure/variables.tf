#######################################
# Yandex.cloud SECRET VARS
#######################################
## cloud-folder id
variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  sensitive   = true
}

#######################################
# Yandex.cloud DEFAULTS
#######################################
## List of zones
variable "vpc_zones" {
  type        = list(string)
  description = "List of zones (count must be equal to 'var.vpc_zones_count')"
  default     = ["ru-central1-a"]
}

#######################################
# Yandex.cloud NETWORK VARS
#######################################
## default network name
variable "vpc_name" {
  type        = string
  description = "VPC network"
  default     = "develop"
}
## Subnets names
variable "subnets_name" {
  type = map(string)
  description = "Subnets names"
  default = {
    "public" = "public",
    "private" = "private"
  }
}
## Subnets data
variable "subnets_data" {
  type = map(list(object({
    zone : string,
    cidr : list(string)
  })))
  description = "Subnets info - map of lists: key - subnets name, value - list of subnets ([{zone,cidr}])"
  default = {
    "public":[
      {
        zone: "ru-central1-a", 
        cidr: ["10.1.1.0/24"]
      }
    ],
    "private": []
  }
}

#######################################
# NAT - ВМ NAT INSTANCE
####################################### 
## Имя статической таблицы маршрутизации
variable "route_table_name" {
  type        = string
  description = "Routing table name (for NAT)"
  default     = "nat-instance-route"
}
## Будет ли создаваться ВМ NAT INSTANCE?
variable "vm_nat_enable" {
  type        = bool
  description = "Wether to create VM NAT instance?"
  default     = true
}
## VM NAT name (used in VM name)
variable "vm_nat_name" {
  type        = string
  description = "VM NAT name"
  default     = "nat"
}
## VM NAT OS family (used in yandex_compute_image)
variable "vm_nat_os_family" {
  type        = string
  description = "OS family for NAT from Yandex.CLoud ('yc compute image list --folder-id standard-images')"
  default     = "nat-instance-ubuntu"
}
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
