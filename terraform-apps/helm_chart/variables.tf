#######################################
# NAMESPACE
#######################################
## Namespace MONITORING
variable "chart_namespace" {
  type        = string
  description = "Chart namespace name where to create pods"
  default     = "default"
}

#######################################
# CHART VARS
#######################################
## Chart name
variable "chart_name" {
  type        = string
  description = "Chart name"
  default     = "chart"
}
## chart repository
variable "chart_repo_url" {
  type        = string
  description = "chart helm repository"
}
## chart helm name in repo
variable "chart_repo_name" {
  type        = string
  description = "chart helm name in repo"
}
## chart helm chart version
variable "chart_version" {
  description = "Version of chart chart"
  type        = string
  default     = null
}

## File with additional settings (format .yaml)
variable "additional_settings_file" {
  description = "## File with additional settings (format .yaml)"
  type        = string
  default     = null
}
