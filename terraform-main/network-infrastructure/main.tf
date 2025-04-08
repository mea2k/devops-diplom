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
  count = var.vpc_zones_count

  name           = "${var.subnet_public_name}-${var.vpc_zones[count.index]}"
  zone           = var.vpc_zones[count.index]
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = [var.subnet_public_cidr[count.index]]
}

## Подсеть PRIVATE
## X шт в разных зонах
resource "yandex_vpc_subnet" "private" {
  count = var.vpc_zones_count

  name           = "${var.subnet_private_name}-${var.vpc_zones[count.index]}"
  zone           = var.vpc_zones[count.index]
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = [var.subnet_private_cidr[count.index]]
  route_table_id = yandex_vpc_route_table.nat_route[count.index].id
}

#######################################
# NAT - ТАБЛИЦА МАРШРУТИЗАЦИИ
####################################### 
## Таблица маршрутизации и статический маршрут
## Всего X таблиц (по 1й на каждую PRIVATE подсеть)
resource "yandex_vpc_route_table" "nat_route" {
  count = var.vm_nat_enable == true ? var.vpc_zones_count : 0

  name       = "${var.route_table_name}-${var.vpc_zones[count.index]}"
  network_id = yandex_vpc_network.vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat_instance[count.index].network_interface.0.ip_address
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
resource "yandex_compute_instance" "nat_instance" {
  count = var.vm_nat_enable == true ? var.vpc_zones_count : 0

  name        = "${var.vm_nat_name}-${var.vpc_zones[count.index]}"
  hostname    = "${var.vm_nat_name}-${var.vpc_zones[count.index]}"
  platform_id = var.vms_resources["nat"].platform_id
  zone        = var.vpc_zones[count.index]
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
    subnet_id = yandex_vpc_subnet.public[count.index].id
    nat       = var.vms_resources["nat"].enable_nat
  }

  # metadata = {
  #   serial-port-enable = local.vms_metadata.serial_port_enable #1
  #   ssh-keys           = local.vms_metadata.ssh_keys[0]        #"ubuntu:${var.vms_ssh_root_key}"
  # }
  metadata = local.vms_metadata_public_image
}
