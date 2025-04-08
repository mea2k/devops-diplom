output "net" {
  value = {
    default_security_group_id = yandex_vpc_network.vpc.default_security_group_id
    id                        = yandex_vpc_network.vpc.id
    name                      = yandex_vpc_network.vpc.name
    subnet_ids                = yandex_vpc_network.vpc.subnet_ids
  }
}

output "public" {
  value = [for s in yandex_vpc_subnet.public : {
    name = s.name,
    zone = s.zone,
    cidr = s.v4_cidr_blocks[0],
    id   = s.id
  }]
}

output "private" {
  value = [for s in yandex_vpc_subnet.private : {
    name = s.name,
    zone = s.zone,
    cidr = s.v4_cidr_blocks[0],
    id   = s.id
  }]
}

output "route_table" {
  value = yandex_vpc_route_table.nat_route
}

output "vm_nat" {
  value = yandex_compute_instance.nat_instance
}