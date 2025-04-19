#######################################
# YANDEX APPLICATION LOAD BALANCER (ALB)
#######################################
## default ALB name
variable "app_balancer_name" {
  type        = string
  description = "ALB Name (default 'alb')"
  default     = "alb"
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

## VPC Network ID
variable "vpc_network_id" {
  type        = string
  description = "VPC Network ID"
}

## List of Public subnets data
variable "vpc_public_subnets" {
  type = list(object({
    name : string,
    zone : string,
    cidr : string,
    id : string
  }))
  description = "List of Public subnets [{name, zone, cidr, id}]"
}

## ALB External Ports for listenning (list({from, to}))
variable "app_balancer_ports" {
  type = list(object({
    from : number,
    to : number
  }))
  description = "ALB External Ports for listenning (list({from, to}))"
  default     = [{ from : 8080, to : 8080 }]
}

## Servers healthcheck URL
variable "app_balancer_healthcheck_url" {
  type        = string
  description = "Servers healthcheck URL"
  default     = "/"
}
## Servers healthcheck Port
variable "app_balancer_healthcheck_port" {
  type        = string
  description = "Servers healthcheck port"
}

## Public IP
variable "public_ip" {
  type        = string
  description = "Public IP"
  default     = null
}