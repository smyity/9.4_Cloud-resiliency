# создание облачной сети
resource "yandex_vpc_network" "net_cloud01" {
  name = "network-${var.flow}"
}

# создание подсети zone A
resource "yandex_vpc_subnet" "block_1" {
  name           = "block_1-${var.flow}-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net_cloud01.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}