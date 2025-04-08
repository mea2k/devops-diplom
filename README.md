# devops-diplom


## 1. Подготовка инфраструктуры терраформ


1. Создание каталога в Яндекс.Облаке

2. Добавление прав доступа к каталогу для существующего сервисного аккаунта с правами: `compute.editor`, `editor`, `iam.admin`, `kms.admin`, `kms.keys.encrypterDecrypter`, `resource-manager.admin`, `storage.admin`

3. Запуск предварительной настройки terraform от имени указанного сервисного аккаунта 

	1. Создать файл `secret.auto.tfvars` и добавить значение перменных `token`, `cloud_id`, `folder_id` ([terraform-init/variables.tf](terraform-init/variables.tf#L5)) 

	2. _(при необходимости)_ Изменить значения переменных в файле [terraform-init/variables.auto.tfvars](terraform-init/variables.auto.tfvars) 

	3. Выполнить команду запуска

		```
		terraform -chdir=./terraform-init apply -var-file=../secret.auto.tfvars

		```

4. Получение файла с ключами от созданного в п.3 сервисного аккаунта

	```
	yc iam key create --output terraform-main/sa_key.json --service-account-name=terraform-sa --folder-id=<folder-id>
	```

5. Инициализация основного проекта terraform (поменялись учетные данные раздела 'backend' для хранения .tfstate в объектном хранилище Яндекс Облака)

	```
	terraform -chdir=./terraform-main init -backend-config=backend.secret.tfvars -reconfigure
	```

6. Запуск создания основной инфраструктуры

	```
	terraform -chdir=./terraform-main apply -var-file=../secret.auto.tfvars
	```






------

## Полезные дополнительные материалы, которые пригодились для выполнения задания


[Установка kubernetes через kubespray - habr](https://habr.com/ru/articles/426959/)

[https://dev.to/admantium/kubernetes-installation-tutorial-kubespray-46ek?ysclid=m97m4b14sh390719292](https://dev.to/admantium/kubernetes-installation-tutorial-kubespray-46ek?ysclid=m97m4b14sh390719292)

[https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec](https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec)


------ 

# Задание

[https://github.com/netology-code/devops-diplom-yandexcloud](https://github.com/netology-code/devops-diplom-yandexcloud)
