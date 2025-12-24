# создаем облачную сеть
resource "yandex_vpc_network" "net_cloud01" {
  name = "network-${var.flow}"
}

# создаем подсеть zone A
resource "yandex_vpc_subnet" "block_1" {
  name           = "block_1-${var.flow}-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net_cloud01.id
  v4_cidr_blocks = ["10.0.1.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

# создаем NAT для выхода в интернет машинам "ubuntu_workstation"
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "gateway-${var.flow}"
  shared_egress_gateway {}
}

# создаем сетевой маршрут для выхода в интернет через NAT
resource "yandex_vpc_route_table" "rt" {
  name       = "route-table-${var.flow}"
  network_id = yandex_vpc_network.net_cloud01.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# группы безопасности
resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion-sg-${var.flow}"
  network_id = yandex_vpc_network.net_cloud01.id
  ingress {
    description    = "SSH"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 32545
  }
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "LAN" {
  name       = "LAN-sg-${var.flow}"
  network_id = yandex_vpc_network.net_cloud01.id
# входящий трафик
  ingress {
    description    = "Allow 10.0.0.0/8" # описание
    protocol       = "ANY"
    v4_cidr_blocks = ["10.0.0.0/8"]
    from_port      = 0
    to_port        = 65535
  }
# исходящий трафик
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

}

resource "yandex_vpc_security_group" "locker" {
  name       = "locker-${var.flow}"
  network_id = yandex_vpc_network.net_cloud01.id
  ingress {
    description    = "SSH"
    protocol       = "TCP"
    v4_cidr_blocks = ["10.0.1.0/24"]
    port           = var.ssh_port
  }
  ingress {
    description    = "HTTP"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    description    = "HTTPS"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
