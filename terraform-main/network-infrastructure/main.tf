#######################################
# СЕТЬ
#######################################
## Основная сеть
resource "yandex_vpc_network" "vpc" {
  name = var.vpc_name
}
## Подсеть PUBLIC
## X шт в разных зонах
resource "yandex_vpc_subnet" "public" {
  for_each = {for k, v in var.subnets_data.public: k => v}

  name           = "${var.subnets_name.public}-${each.value.zone}-${each.key + 1}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = each.value.cidr
}

## Подсеть PRIVATE
## X шт в разных зонах
resource "yandex_vpc_subnet" "private" {
  for_each = {for i, v in var.subnets_data.private: i => v}

  name           = "${var.subnets_name.private}-${each.value.zone}-${each.key + 1}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = each.value.cidr
  route_table_id = var.vm_nat_enable == true ? local.nat_route_by_zone[each.value.zone].id : null
}

#######################################
# NAT - ТАБЛИЦА МАРШРУТИЗАЦИИ
####################################### 
## Таблица маршрутизации и статический маршрут
## Всего X таблиц (по 1й на каждую зону)
resource "yandex_vpc_route_table" "nat_route" {
  for_each = var.vm_nat_enable == true ? { for i,v in var.subnets_data.private: i => v} : {}

  name       = "${var.route_table_name}-${each.value.zone}-${each.key + 1}"
  labels      = {"zone": each.value.zone}
  network_id = yandex_vpc_network.vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = local.vm_nat_by_zone[each.value.zone].network_interface[0].ip_address
  }
}

#######################################
# NAT - ВМ NAT INSTANCE
#######################################
## Образ загрузочного диска
data "yandex_compute_image" "nat_boot" {
  count = var.vm_nat_enable == true ? 1 : 0

  family = var.vm_nat_os_family
}
## VM-NAT
## по 1-й на каждую зону
resource "yandex_compute_instance" "nat_instance" {
  for_each = var.vm_nat_enable == true ? {for i,v in var.vpc_zones: i => v} : {}

  name        = "${var.vm_nat_name}-${each.value}-${each.key + 1}"
  hostname    = "${var.vm_nat_name}-${each.value}-${each.key + 1}"
  platform_id = var.vms_resources["nat"].platform_id
  zone        = each.value
  resources {
    cores         = var.vms_resources["nat"].cores
    memory        = var.vms_resources["nat"].memory
    core_fraction = var.vms_resources["nat"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.nat_boot.0.id
      size     = var.vms_resources["nat"].hdd_size
      type     = var.vms_resources["nat"].hdd_type
    }
  }
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }

  scheduling_policy {
    preemptible = var.vms_resources["nat"].preemptible
  }

  network_interface {
    index     = 0
    subnet_id = local.public_net_by_zone[each.value]
    nat       = var.vms_resources["nat"].enable_nat
  }

  # metadata = {
  #   serial-port-enable = local.vms_metadata.serial_port_enable #1
  #   ssh-keys           = local.vms_metadata.ssh_keys[0]        #"ubuntu:${var.vms_ssh_root_key}"
  # }
  metadata = local.vms_metadata_public_image
}