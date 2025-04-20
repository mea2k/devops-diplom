terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">=0.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.18.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.9.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">2.5.0"
    }
  }
  required_version = "~>1.8.4"
}

provider "yandex" {
  service_account_key_file = "sa_key.json"
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
}


provider "kubernetes" {
  config_path = var.kubernetes_config_file #"~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = var.kubernetes_config_file
  }
}

provider "local" {}
