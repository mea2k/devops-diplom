#######################################
# Yandex.cloud NETWORK LOAD BALANCER (NLB)
#######################################
## default NLB name
variable "nlb_name" {
  type        = string
  description = "NLB Name (default 'nlb')"
  default     = "nlb"
}
## NLB External Port for listenning
variable "nlb_ext_port" {
  type        = number
  description = "NLB External Port for listenning"
}
## NLB Internal Port for queries
variable "nlb_int_port" {
  type        = number
  description = "NLB Internal Port for queries"
}
## NLB Healthcheck Port
variable "nlb_healthcheck_port" {
  type        = number
  description = "NLB healthcheck Port"
}
## Servers healthcheck URL
variable "nlb_healthcheck_url" {
  type        = string
  description = "Servers healthcheck URL"
  default     = "/"
}

## Enable Public IP
## (if true and not set public_ip new will be created)
variable "enable_public_ip" {
  description = "Enable public IP. If true and PUBLIC_IP not set, public IP will be created"
  type        = bool
  default     = true
}
## Public IP (if exists)
## If not and ENABLE_PUBLIC_IP is true - it will be created
variable "public_ip" {
  description = "Public IP address for the network load balancer"
  type        = string
  default     = null
}
## Public IP Zone
variable "public_ip_zone" {
  description = "Public IP Zone"
  type        = string
  default     = "ru-central1-a"
}
## IP protocol family {"ipv4"|"ipv6"}
variable "ip_version" {
  description = "IP protocol family {'ipv4' | 'ipv6'}"
  type        = string
  default     = "ipv4"
}

## VM Master data
variable "vm_master" {
  type = list(object({
    fqdn : string,
    id : string,
    name : string,
    ip : string,
    nat_ip : string,
    zone : string,
    network_id : string,
  }))
  description = "VM Master Data list (list(object({fqdn,id,name,ip,nat_ip,zone,network_id}))"
}
