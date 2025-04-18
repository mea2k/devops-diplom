# ДИПЛОМНАЯ РАБОТА ПО КУРСУ "DEVOPS-ИНЖЕНЕР"


## 1. Описание стенда

### Схема стенда

Стенд представляет собой отказоустойчивый (High Availability) Kubernetes-кластер, состоящий из 3 мастеров и 4-х рабочих узлов. Все узлы создаются в Яндекс.Облаке.

![Схема стенда](images/stand.png)


_Особенности стенда_

1. Для обеспечения отказоустойчивости используются все доступные зоны Яндекс.Облака (`"ru-central1-a", "ru-central1-b", "ru-central1-c"`).

2. В каждой зоне присутствует по 1-му мастеру. БД `etcd` развернута только на мастерах. НА них стоит запрет на планирование и выполнение задач (`no-schedule`).

3. Предполагается, что наибольшая нагрузка по трафику будет в зоне `"ru-central1-a"`, поэтому в ней 2 рабочих узла, в остальных по 1-му рабочему узлу.

4. Для обесмпечения доступности кластера предусмотрен сетевой балансировщик от Яндекс.Облака (NLB), который перенаправляет запросы с внешнего IP-адреса, порт 8888, на один из мастер-серверов на внутренний порт 6443. Алгоритм ротации - `round-robin` + проверка на доступность (`keepalive` по порту 6443).

5. Для доступа к приложениям извне, предусмотрен балансировщик уровня приложения от Яндекс.Облака (ANB), который перенапрааляет запросы с внешнего IP-адреса на диапазон портов, на группу серверов (мастера) и такой же HTTP-порт. Предусмотрен механизм `keepalive` (`/healthz` по порту 6443).




### Компоненты стенда




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

[https://habr.com/ru/articles/725640/](https://habr.com/ru/articles/725640/)


[Шифрование бакета - Yandex.Cloud](https://yandex.cloud/ru/docs/storage/operations/buckets/encrypt)

[Yandex Storage Bucket](https://terraform-provider.yandexcloud.net/resources/storage_bucket#nestedblock--lifecycle_rule--transition)

[https://fauzislami.github.io/blog/2021/10/17/highly-available-kubernetes-cluster-with-haproxy-and-keepalived/](https://fauzislami.github.io/blog/2021/10/17/highly-available-kubernetes-cluster-with-haproxy-and-keepalived/)


[https://fauzislami.github.io/blog/2021/10/17/highly-available-kubernetes-cluster-with-haproxy-and-keepalived/](https://fauzislami.github.io/blog/2021/10/17/highly-available-kubernetes-cluster-with-haproxy-and-keepalived/)

------ 

# Задание

[https://github.com/netology-code/devops-diplom-yandexcloud](https://github.com/netology-code/devops-diplom-yandexcloud)
