# ДИПЛОМНАЯ РАБОТА ПО КУРСУ "DEVOPS-ИНЖЕНЕР"

## 1. Описание стенда

### Схема стенда

Стенд представляет собой отказоустойчивый (High Availability) Kubernetes-кластер, состоящий из 3 мастеров и 4-х рабочих узлов. Все узлы создаются в Яндекс.Облаке.

![Схема стенда](images/stand.png)

#### _Особенности стенда_

1. Для обеспечения отказоустойчивости используются все доступные зоны Яндекс.Облака (`"ru-central1-a", "ru-central1-b", "ru-central1-c"`).

2. В каждой зоне присутствует по 1-му мастеру. БД `etcd` развернута только на мастерах. На них стоит запрет на планирование и выполнение задач (`no-schedule`).

3. Предполагается, что наибольшая нагрузка по трафику будет в зоне `"ru-central1-a"`, поэтому в ней 2 рабочих узла, в остальных по 1-му рабочему узлу.

4. Для обеспечения доступности кластера предусмотрен сетевой балансировщик от Яндекс.Облака (NLB), который перенаправляет запросы с внешнего IP-адреса, порт `8888`, на один из мастер-серверов на внутренний порт `6443`. Алгоритм ротации - `round-robin` + проверка на доступность (`keepalive` по порту `6443`).

5. Для доступа к приложениям извне, предусмотрен балансировщик уровня приложения от Яндекс.Облака (ALB), который перенаправляет запросы с внешнего IP-адреса на диапазон портов, на группу серверов (мастера) и определенный HTTP-порт.

6. Предусмотрен механизм `keepalive` для мастеров. Для этого на них установлен nginx, выдающий статическую страницу по пути `/` и порту `8080`.

### Компоненты стенда

__Схема сети от Яндекса__

![Схема сети](images/stand-yandex.png)

__Балансировщик уровня приложения (ALB)__

![Структура ALB](images/alb-01.png)


## 2. Подготовка инфраструктуры terraform

1. Создание каталога в Яндекс.Облаке (значение `folder_id`)

2. Добавление прав доступа к каталогу для существующего сервисного аккаунта с правами: `compute.editor`, `editor`, `iam.admin`, `kms.admin`, `kms.keys.encrypterDecrypter`, `resource-manager.admin`, `storage.admin`, `load-balancer.admin`.

3. Запуск предварительной настройки terraform от имени указанного сервисного аккаунта

    1. Создать файл `secret.auto.tfvars` и добавить значение переменных `token`, `cloud_id`, `folder_id` ([terraform-init/variables.tf](terraform-init/variables.tf#L5))

    2. _(при необходимости)_ Изменить значения переменных в файле [terraform-init/variables.auto.tfvars](terraform-init/variables.auto.tfvars)

    3. Выполнить команду запуска

      ```shell
        terraform -chdir=./terraform-init apply -var-file=../secret.auto.tfvars
      ```

4. Получение файла с ключами от созданного в п.3 сервисного аккаунта

    ```shell
    yc iam key create --output terraform-main/sa_key.json --service-account-name=terraform-sa --folder-id=<folder-id>
    ```

5. Инициализация основного проекта terraform (добавление учетных данных созданного сервисного аккаунт, и настройка хранения файла состояния .tfstate в объектном хранилище Яндекс Облака)

    ```shell
    terraform -chdir=./terraform-main init -backend-config=backend.secret.tfvars -reconfigure
    ```

6. Запуск создания основной инфраструктуры

    ```shell
    terraform -chdir=./terraform-main apply -var-file=../secret.auto.tfvars
    ```

    _Установка кластера занимает ~25 минут._

7. Изменение конфигурационного файла кластера по пути `~/.kube/config` - файл создаётся автоматически

    ```shell
    nano ~/.kube/config
    ```

    В файле необходимо заменить IP-адрес подключения на внешний IP-адрес балансировщика нагрузки и порт подключения на внешний порт. информация отображается в выходных данных terraform-main

    ```text
    nlb = {
      "address" = "<external-control-IP>"
      "ext_port" = 8888
      "name" = "kube-nlb-ext"
      "target_port" = 6443
    }
    ```

8. Проверка работы кластера

    ```shell
    kubectl get nodes
    ```

    _Ожидаемый результат:_

    ![Результат развертывания кластера](images/kubectl-nodes-01.png)

9. Проверка корректности работы балансировщика - обращение по внешнему IP-адресу по пути `/` на порт `8080` несколько раз. IP=адрес доступен в выходных данных terraform-main

    ```text
    alb = {
      "address" = "<external-app-IP>"
      "name" = "kube-alb"
      "ports" = tolist([
      80,
      9000,
      9001,
      10000,
      8080,
      ])
    }
    ```

    _Ожидаемый результат:_ изменение содержимого html-страницы

    ![Результат проверки работы балансировщика](images/nginx-8080.png)

__Результат:__

1. Созданная инфраструктура отказоустойчивого кластера Kubernetes с внешними балансировщиками нагрузки для управления и для приложений.

2. Настроенный конфигурационный файл для управления кластером с помощью команды `kubectl`.

3. Внешний IP-адрес для взаимодействия с приложениями, запущенными внутри кластера (`<external-app-IP>`).

## 2. Установка Prometheus, Grafana, Node Exporter

Для установки Prometheus, Grafana, AlertManager используется helm-сборка `kube-prometheus-stack`. Установка осуществляется в отдельном terraform-проекте [terraform-apps](terraform-apps/main.tf) с использованием провайдера `helm` ([terraform-apps/providers.tf](terraform-apps/providers.tf)).

Конфигурационный файл - [terraform-apps/prometheus-stack/values/prometheus.yaml](terraform-apps/prometheus-stack/values/prometheus.yaml).

Для запуска проекта необходимо выполнить команды:

```shell
terraform -chdir=./terraform-apps init
terraform -chdir=./terraform-apps apply -var-file=../secret.auto.tfvars
```

### Альтернативный вариант

Подготовлены файлы для ручной настройки `Prometheus`, `Grafana`, `NodeExplorer`, `AlertManager`, `Teamcity`.

Файлы находятся в папке [kubernetes](kubernetes/). Там же есть инструкция ([readme](kubernetes/readme.md)).

__Результат:__

Созданное пространство имен `namespace`, в котором развернуты поды и службы Prometheus.

![Созданное пространство имен](images/prometheus-namespace.png)

Созданные контейнеры, службы, приложения

![Созданные контейнеры, службы, приложения](images/prometheus-all.png)

По выделенному порту (`30238`) доступен web-интерфейс Grafana. В балансировщике нагрузки ([terraform-main/app-load-balancer](terraform-main/app-load-balancer/main.tf)) создано правило перенаправления HTTP-трафика с порта 80 на порт `30238` (переменная `app_balancer_ports` в файле [terraform-main/variables.auto.tfvars](terraform-main/variables.auto.tfvars#L59)).

Таким образом, Grafana доступна по `<external-app-IP>` и порту `80`.

![Web-интерфейс Grafana](images/grafana-01.png)

## 3. Настройка CI/CD terraform-проекта

### Gitlab

Для настройки CI/CD была подготовлена виртуальная машина с установленным Gitlab, куда был импортирован текущий проект из github.

Доступ к gitlab: [http://158.160.38.199](http://158.160.38.199) (`root:qwe123!@#`)

### Pipeline

1. Импорт проекта из github.

2. Создание и заполнение файла [.gitlab-ci.yml](.gitlab-ci.yml)

    - описание этапов обработки: `validate`, `plan`, `apply`, `destroy`

    - описание обработчиков каждого этапа с вызовом команды `terraform ...`

3. Добавление необходимых переменных, содержащих ключевую и парольную информацию, а также переменные из [secret.auto.tfvars](secret.auto.tfvars)

    Файл `sa_key.json` предварительно был закодирован base64 и скопирован в переменную `$YC_KEY`.

    Требуется дописать вручную переменные `bucket`, `region`, `key` в файле [terraform-main/backend.tf](terraform-main/backend.tf).

    ![Добавленные переменные окружения в PIpeline](images/terraform-pipeline-02.png)

4. Установка `gitlab-runner` вместе с `terraform` на отдельной ВМ `vm-control-1` и регистрация раннера типа `shell`.

5. Изменение кода проекта и анализ проработки pipeline

    ![Результат выполнения pipeline](images/terraform-pipeline-01.png)

    - этап `validate`

      ![Этап Validate](images/terraform-pipeline-validate-01.png)

    - этап `plan`

      ![Этап Plan](images/terraform-pipeline-plan-01.png)

    - этап `apply`

      ![Этап Apply](images/terraform-pipeline-apply-01.png)

## Тестовое приложение

Разработано web-прилжение __"DevOps-HTML"__ - [https://github.com/mea2k/simple-html](https://github.com/mea2k/simple-html)

Собранный docker-образ размещён в

- Yandex.Registry - [Yandex.Registry](https://console.yandex.cloud/folders/b1gsts59vmstq2dmi9c9/container-registry/registries/crpg9ie34hq65l49usj2/overview/devops-html/image), сам образ доступен по имени: `yandex/crpg9ie34hq65l49usj2/devops-html`

- dockerhub-репозитории - [makevg/devops-html](https://hub.docker.com/r/makevg/devops-html/tags), сам образ доступен по имени: `makevg/devops-html`

В репозитории содержатся файлы для развёртывания приложения в кластере:

- [configMap](https://github.com/mea2k/simple-html/kubernetes/configmap.yaml)
- [deployment](https://github.com/mea2k/simple-html/kubernetes/deployment.yaml)
- [service](https://github.com/mea2k/simple-html/kubernetes/service.yaml)

  По умолчанию, контейнер запускается на порту `80`.

## CI/CD тестового приложения

### Приложение

Для автоматического развертывания подготовлено web-приложение `devops-html`. Репозиторий проекта: [https://github.com/mea2k/simple-html](https://github.com/mea2k/simple-html).

### Gitlab

Для настройки CI/CD была подготовлена виртуальная машина с установленным Gitlab, куда был импортирован проект приложения из github.

Доступ к gitlab: [http://158.160.38.199](http://158.160.38.199) (`root:qwe123!@#`)


### Pipeline

1. Импорт проекта из github.

2. Создание и заполнение файла [.gitlab-ci.yml](https://github.com/mea2k/simple-html/blob/main/.gitlab-ci.yml) для приложения:

    - описание этапов обработки: `build`, `deploy`

    - описание обработчиков каждого этапа с вызовом `gitlab-runner`-а и команд `kubectl ...`

3. Добавление необходимых переменных, содержащих конфигурационный файл подключения к кластеру, а также другие переменные для работы с Yandex.Registry:

    - `CI_REGISTRY` - идентификатор созданного Yandex.Registry

    - `CI_REGISTRY_KEY` - данные сервисного аккаунта для доступа к Yandex.Registry (это содержимое файла `sa_key.json`, полученного при выполнении проекта [terraform-init](terraform-init/))
    
    - `KUBE_CONFIG` - содержимое конфигурационного файла для подключения к kubernetes-кластеру (создан после выполнения проекта [terraform-main](terraform-main/))

    - `YR_EMAIL` - yandex-email учетной записи, в которой создан Yandex.Registry

    - `YR_OAUTH_TOKEN` - токен подключения к Yandex.Registry ([https://oauth.yandex.ru/verification_code](https://oauth.yandex.ru/verification_code))
    
    ![Добавленные переменные окружения в PIpeline](images/cicd-variables.png)

4. Установка `gitlab-runner` типа `docker` для осуществления сборки и размещения образа в кластере. Сделано это на локальной ВМ.

    ![Обработчики процессов CI/CD](images/cicd-runners.png)

5. Добавление коммита и отслеживание хода выполнения pipeline

    ![Результат выполнения pipeline](images/cicd-pipeline-01.png)

    - этап `build`

      ![Этап build](images/cicd-stages-build-01.png)

    - этап `deploy`

      ![Этап Deploy](images/cicd-stages-deploy-01.png)

6. Результат развертывания в кластере

    - добавленный образ в Yandex.Registry

      ![Добавленный образ в Yandex.Registry](images/yandex-registry.png)

    - результат развертывания в кластере
    
      ![Результат развертывания в кластере](images/cicd-result-01.png)

    - доступ к самому приложению, запущенному в кластере

      ![Открытое приложение в кластере](images/html-app.png)


## Доступные ресурсы кластера

На текущий момент доступны следующие ресурсы кластера

- [http://89.169.150.56/](http://89.169.150.56/) - Grafana

- [http://89.169.150.56:9090](http://89.169.150.56:9090) - Prometheus

- [http://89.169.150.56:9099/](http://89.169.150.56:9099/) - AlertManager

- [http://89.169.150.56:9000/](http://89.169.150.56:9000/) - Teamcity

- [http://89.169.150.56:3000/](http://89.169.150.56:3000/) - web-приложение __"DevOps-html"__




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

[Atlantis](https://docs.vultr.com/run-terraform-in-automation-with-atlantis)

[https://habr.com/ru/articles/752586/](https://habr.com/ru/articles/752586/)

[Хранение docker-образов в Yandex Container Registry](https://yandex.cloud/ru/docs/managed-gitlab/tutorials/image-storage)

[https://dzen.ru/a/XPaLoluskQCw1AgU](https://dzen.ru/a/XPaLoluskQCw1AgU)

------

# Задание

[https://github.com/netology-code/devops-diplom-yandexcloud](https://github.com/netology-code/devops-diplom-yandexcloud)
