# УСТАНОВКА ПРИЛОЖЕНИЙ НА КЛАСТЕР KUBERNETES

## Установка систем мониторинга (Prometheus + Grafana + AlertManager + NodeExporter)

Используемые порты:

- __Prometheus__:
  - порт контейнера: `9090` (`targetPort`)
  - порт узла: `31090` (`nodePort`)
  - внешний порт: `9090`

- __Grafana__:
  - порт контейнера: `3000` (`targetPort`)
  - порт узла: `31000` (`nodePort`)
  - внешний порт: `80`

- __Alert Manager__:
  - порт контейнера: `9099` (`targetPort`)
  - порт узла: `31099` (`nodePort`)
  - внешний порт: `9099`

- __Node Exportet__:
  - порт контейнера: `9100` (`targetPort`)
  - портport узла: `9100` (`nodePort`)
  - внешний порт: -

__Порядок запуска команд:__

```bash
kubectl apply -f monitoring/general.yaml
kubectl apply -f monitoring/prometheus/prometheus-pv.yaml
kubectl apply -f monitoring/prometheus/prometheus-config.yaml
kubectl apply -f monitoring/prometheus/prometheus-deploy.yaml
kubectl apply -f monitoring/alertmanager/alertmanager-config.yaml
kubectl apply -f monitoring/alertmanager/alertmanager-statefulset.yaml
kubectl apply -f monitoring/grafana/grafana-pv.yaml
kubectl apply -f monitoring/grafana/grafana-config.yaml
kubectl apply -f monitoring/grafana/grafana-deploy.yaml
kubectl apply -f monitoring/node-exporter.yaml
```

Необходимо поменять права папок на всех рабочих узлах (`worker-N`), в которых хранятся созданные PersistentVolume.

_Особенность Prometheus - он запускает все контейнеры от имени `nobody:nogroup`, а папки на узлах создаются от имени `root`._

Команды на всех узлах `worker-N`:

```bash
sudo chmod -R 775 /mnt/data/prometheus
sudo chmod -R 775 /mnt/data/grafana
sudo chown -R 65534:65534 /mnt/data/prometheus
sudo chown -R 65534:65534 /mnt/data/grafana
```

## Установка DevOps инструментов (Teamcity)

Используемые порты:

- __Teamcity-server__:
  - порт контейнера: `8111` (`targetPort`)
  - порт узла: `31111`  (`nodePort`)
  - внешний порт: `9000`

- __Teamcity-client__:
  - порт контейнера: `9090` (`targetPort`)
  - порт узла: `8888`  (`nodePort`)
  - внешний порт: -

```bash
kubectl apply -f devops/general.yaml
kubectl apply -f devops/teamcity/teamcity-pv.yaml
kubectl apply -f devops/teamcity/teamcity-server.yaml
kubectl apply -f devops/teamcity/teamcity-agent.yaml
```

_Особенность Teamcity - он запускает все контейнеры от имени `1000:1000`, а папки на узлах создаются от имени `root`._

Команды на всех узлах `worker-N`:

```bash
sudo chmod -R 777 /mnt/data/teamcity
sudo chown -R 1000:1000 /mnt/data/teamcity
```
