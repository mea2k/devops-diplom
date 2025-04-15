---
all:
  hosts:
%{ for vm in vm_master ~}
    ${vm.name}:
      ansible_host: ${vm.network_interface[0].ip_address}
      access_ip: ${vm.network_interface[0].ip_address}
%{ endfor ~}
%{ for vm in vm_worker ~}
    ${vm.name}:
      ansible_host: ${vm.network_interface[0].ip_address}
      access_ip: ${vm.network_interface[0].ip_address}
%{ endfor ~}
  children:
    kube_control_plane:
      hosts:
%{ for vm in vm_master ~}
        ${vm.name}:
%{ endfor ~}
    kube_node:
      hosts:
%{ for vm in vm_worker ~}
        ${vm.name}:
%{ endfor ~}
    etcd:
      hosts:
%{ for vm in vm_master ~}
        ${vm.name}:
%{ endfor ~}
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
  vars:
    ansible_connection_type: paramiko
    ansible_user: ${ansible_user}
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'