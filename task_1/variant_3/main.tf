# ОС Ubuntu 22.04 LTS
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "ubuntu_workstation" {
  # количество идентичных машин
  count       = length(var.vm_name)
  
  name        = var.vm_name[count.index]
  hostname    = var.vm_name[count.index]
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    user-data          = templatefile("${path.module}/cloud-init.tftpl", {ssh_port = var.ssh_port, user = var.vm_user})

    serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.block_1.id
    nat                = true
    security_group_ids = [ yandex_vpc_security_group.locker.id ]
  }
}

# целевая группа
resource "yandex_lb_target_group" "tg01" {
  name      = "target-group-01"
  region_id = "ru-central1"

  # Динамический блок перебирает все созданные ВМ и добавляет их в группу
  dynamic "target" {

    for_each = yandex_compute_instance.ubuntu_workstation
    
      content {
        subnet_id = target.value.network_interface.0.subnet_id
        address   = target.value.network_interface.0.ip_address
      }
    }
}

# сетевой балансировщик
resource "yandex_lb_network_load_balancer" "web-lb" {
  name = "web-network-load-balancer"

  # Настройка входа (слушателя)
  listener {
    name        = "http-listener"
    port        = 80   # порт, который слушает балансировщик
    target_port = 80   # порт на самой виртуальной машине
  }

  # привязка целевой группы к балансировщику
  attached_target_group {
    target_group_id = yandex_lb_target_group.tg01.id

    # проверка состояния ВМ
    healthcheck {
      name = "http-check"
      http_options {
        port = 80
        path = "/" # Путь для проверки
      }
      interval            = 5 # интервал между проверками в секундах (должен быть больше, чем timeout хотя бы на 1 сек)
      timeout             = 2 # время ожидания ответа от цели
      unhealthy_threshold = 2 # количество неудачных healthcheck запросов для установки статуса UNHEALTHY для цели
      healthy_threshold   = 2 # количество удачных healthcheck запросов для установки статуса HEALTHY для цели
    }
  }
}

resource "local_file" "inventory" {
  filename = "./inventory.ini"

  content  = <<-XYZ
[target_group]
%{ for vm in yandex_compute_instance.ubuntu_workstation ~}
${vm.name} ansible_host=${vm.network_interface.0.nat_ip_address} ansible_port=${var.ssh_port} ansible_ssh_private_key_file=~/.ssh/ssh-key-1759501063847
%{ endfor ~}
XYZ
}

resource "local_file" "readme" {
  filename = "./README.txt"

  content  = <<-EOF
For connect to a remote server:
%{ for vm in yandex_compute_instance.ubuntu_workstation }
[${vm.name}]
ssh ${var.vm_user}@${vm.network_interface.0.nat_ip_address} -p ${var.ssh_port}
%{ endfor ~}
EOF
}
