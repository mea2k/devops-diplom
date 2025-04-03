#######################################
# Yandex.cloud SECRET VARS
#######################################
## cloud id
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
  sensitive = true
}
## cloud-folder id
variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  sensitive = true
}

#######################################
# Yandex.cloud DEFAULTS
#######################################
## default network zone (used in yandex_vpc_subnet) - 'ru-central1-a'
variable "default_zone" {
  type        = string
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
  default     = "ru-central1-a"
}
## default cidr
variable "default_cidr" {
  type        = string
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
  default     = "10.0.1.0/24"
}
## Number of zones
variable "vpc_zones_count" {
  type        = number
  description = "Number of zones for cluster"
  default     = 1
}
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
## default PUBLIC net name
variable "subnet_public_name" {
  type        = string
  description = "VPC public subnet name"
  default     = "public"
}
## default PUBLIC net cidr
variable "subnet_public_cidr" {
  type        = list(string)
  description = "VPC public cidr (https://cloud.yandex.ru/docs/vpc/operations/subnet-create)"
  default     = ["10.1.1.0/24"]
}
## default PRIVATE net name
variable "subnet_private_name" {
  type        = string
  description = "VPC private subnet name"
  default     = "private"
}
## default PRIVATE net cidr
variable "subnet_private_cidr" {
  type        = list(string)
  description = "VPC private cidr (https://cloud.yandex.ru/docs/vpc/operations/subnet-create)"
  default     = ["10.2.1.0/24"]
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
