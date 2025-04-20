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
# KUBERNETES CONFIG VARS
#######################################
## Kubernetes config file path and name
variable "kubernetes_config_file" {
  description = "Kubernetes config file path and name"
  type        = string
  default     = "~/.kube/config"
}

#######################################
# NAMESPACE
#######################################
## Namespace MONITORING
variable "monitoring_namespace" {
  type        = string
  description = "Monitoring namespace name"
  default     = "monitoring"
}

#######################################
# PROMETHEUS CONFIG VARS
#######################################

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "my-cluster"
}

variable "prometheus_chart_version" {
  description = "Version of kube-prometheus-stack chart"
  type        = string
  default     = "45.7.1"
}

variable "grafana_chart_version" {
  description = "Version of Grafana chart"
  type        = string
  default     = "6.56.4"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_ingress" {
  description = "Whether to enable Ingress for Grafana"
  type        = bool
  default     = false
}

variable "ingress_host" {
  description = "Ingress host for Grafana"
  type        = string
  default     = "grafana.example.com"
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
## ssh nat port for connecting via nat-instance
variable "vms_ssh_nat_port" {
  type        = number
  description = "ssh nat port for connecting via nat-instance (default - 22000)"
  default     = 22000
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
