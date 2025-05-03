#cloud-config
users:
- name: ${ssh_user}
  groups: sudo
  sudo: 'ALL=(ALL) NOPASSWD:ALL'
  shell: /bin/bash
  ssh_authorized_keys:
  - ${ssh_root_key}
write_files:
  - path: "/usr/local/etc/tf-install.sh"
    permissions: "755"
    content: |
      #!/bin/bash

      # Install Global Ubuntu things
      sudo apt-get -y update
      echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
      sudo apt-get install -y unzip python3 python3-pip pipx

      # Install Terraform
      echo "Installing Terraform"
      sudo curl \
        --silent \
        --show-error \
        --location \
        https://hashicorp-releases.yandexcloud.net/terraform/1.8.5/terraform_1.8.5_linux_amd64.zip \
        --output /usr/local/etc/terraform.zip
      sudo unzip /usr/local/etc/terraform.zip -d /usr/local/etc/
      sudo install -o root -g root -m 0755 /usr/local/etc/terraform /usr/local/bin/terraform
      sudo rm -rf /usr/local/etc/terraform /usr/local/etc/terraform.zip /usr/local/etc/LICENSE.txt
    #defer: true
  - path: "/usr/local/etc/kubectl-install.sh"
    permissions: "755"
    content: |
      #!/bin/bash

      # Install kubectl
      echo "Installing kubectl"
      sudo curl \
        --silent \
        --show-error \
        --location \
        https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl \
        --output /usr/local/etc/kubectl
      sudo install -o root -g root -m 0755 /usr/local/etc/kubectl /usr/local/bin/kubectl
      sudo rm -rf /usr/local/etc/kubectl
  - path: "/usr/local/etc/ansible-install.sh"
    permissions: "755"
    content: |
      #!/bin/bash

      sudo apt-get -y update
      sudo apt-get install -y python3 python3-pip pipx
      sudo apt install -y software-properties-common
      sudo apt install -y git git-extras
      sudo add-apt-repository --yes --update ppa:ansible/ansible
    defer: true
  - path: "/usr/local/etc/helm-install.sh"
    permissions: "755"
    content: |
      #!/bin/bash

      # Install Helm
      echo "Installing Helm"
      sudo curl \
        --silent \
        --show-error \
        --location \
        https://get.helm.sh/helm-v3.15.2-linux-amd64.tar.gz \
        --output /usr/local/etc/helm-v3.15.2-linux-amd64.tar.gz
      sudo tar xf /usr/local/etc/helm-v3.15.2-linux-amd64.tar.gz -C /usr/local/etc/
      sudo install -o root -g root -m 0755 /usr/local/etc/linux-amd64/helm /usr/local/bin/helm
      sudo rm -rf /usr/local/etc/helm-v3.15.2-linux-amd64.tar.gz /usr/local/etc/linux-amd64
    defer: true
runcmd:
  - [su, ${ssh_user}, -c, "/usr/local/etc/tf-install.sh"]
  - [su, ${ssh_user}, -c, "/usr/local/etc/kubectl-install.sh"]
  - [su, ${ssh_user}, -c, "/usr/local/etc/ansible-install.sh"]
  - [su, ${ssh_user}, -c, "/usr/local/etc/helm-install.sh"]
