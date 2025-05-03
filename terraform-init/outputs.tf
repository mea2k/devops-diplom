output "terraform_sa" {
  description = "Terraform Service Account ID for creating instances and other objects in Cloud folder"
  value = {
    id          = yandex_iam_service_account.terraform_sa.id,
    name        = yandex_iam_service_account.terraform_sa.name,
    description = yandex_iam_service_account.terraform_sa.description
    folder_id   = yandex_iam_service_account.terraform_sa.folder_id
  }
}

output "registry" {
  value = {
    id   = yandex_container_registry.registry.id
    name = yandex_container_registry.registry.name
  }
}

output "tfstate_bucket" {
  description = "Object storage for .tfstate"
  value = {
    bucket             = yandex_storage_bucket.tfstate-bucket.bucket,
    bucket_domain_name = yandex_storage_bucket.tfstate-bucket.bucket_domain_name
    id                 = yandex_storage_bucket.tfstate-bucket.id
  }
}

output "sa-key" {
  value = {
    id    = yandex_iam_service_account_static_access_key.sa-static-key.id
    sa_id = yandex_iam_service_account_static_access_key.sa-static-key.service_account_id
  }
}

output "sa-key_secret" {
  value = {
    id    = yandex_iam_service_account_static_access_key.sa-static-key.id
    sa_id = yandex_iam_service_account_static_access_key.sa-static-key.service_account_id
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key 
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key 
  }
  sensitive = true
}