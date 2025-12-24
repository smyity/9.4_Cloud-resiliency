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
}

# группа безопасности
resource "yandex_vpc_security_group" "locker" {
  name       = "locker-${var.flow}"
  network_id = yandex_vpc_network.net_cloud01.id
  ingress {
    description    = "SSH"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
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
