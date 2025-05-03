apiVersion: v1
kind: ConfigMap
metadata:
  name: ${name}
  namespace: ${namespace}
  labels:
    grafana_dashboard: "1"
data:
%{ for filename, content in data ~}
  ${filename}: |
    ${indent(4, content)}
%{ endfor ~}