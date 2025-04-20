#######################################
# TERRAFORM SERVICE ACCOUNT
#######################################
terraform_sa_name                   = "terraform-sa"
terraform_main_path                 = "../terraform-main/"
terraform_main_secret_vars_filename = "backend.secret.tfvars" #(by default)


#######################################
# CONTAINER REGISTRY
#######################################
registry_name = "devops-registry"

#######################################
# Yandex.cloud BUCKET
#######################################
tfstate_bucket_name              = "tfstate"
tfstate_bucket_name_suffix       = "cluster"
tfstate_bucket_key               = "tfstate"
tfstate_bucket_kms_key_name      = "tfstate-bucket-kms-key"
tfstate_bucket_kms_key_algorithm = "AES_256"
tfstate_bucket_kms_key_rotation  = "8760h" # Ротация ключа каждые 365 дней
