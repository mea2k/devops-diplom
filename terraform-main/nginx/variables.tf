#######################################
# VM MASTER VARS
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
