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
}

