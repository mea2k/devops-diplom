#######################################
# VM-CONTROL VARS
#######################################
## Enable creating VM-CONTROL
variable "vm_control_enable" {
  type        = bool
  description = "Wether to create VM-CONTROL ({true | false}) (default - true)"
  default     = true
}
## VM-CONTROL name
variable "vm_control_name" {
  type        = string
  description = "VM-CONTROL name (default - 'vm-control')"
  default     = "vm-control"
}
## VM-CONTROl zone
variable "vm_control_zone" {
  type        = string
  description = "VM CONTROL zone (default - 'ru-central1-a')"
}
## VM-CONTROL subnet ID
variable "vm_control_subnet_id" {
  type        = string
  description = "VM-CONTROL subnet ID"
}
## VM-CONTROL OS family (used in yandex_compute_image)
variable "vm_control_os_family" {
  type        = string
  description = "OS family for VM_CONTROL ('yc compute image list --folder-id standard-images') (default = 'ubuntu-2404-lts-oslogin')"
  default     = "ubuntu-2404-lts-oslogin"
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
    "control" = {
      platform_id   = "standard-v3"
      cores         = 2
      memory        = 2
      core_fraction = 20
      preemptible   = true
      hdd_size      = 20
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
