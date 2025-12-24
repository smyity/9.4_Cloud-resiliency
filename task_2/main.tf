# ОС Ubuntu 22.04 LTS
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance_group" "vm_group_1" {
  name               = "vm-group-1"
  folder_id          = var.folder_id
  service_account_id = "aje7mgasl8gu7m8r9esb"

  instance_template {
    # имя в консоли Yandex Cloud
    name        = "vm-{instance.index}"

    # имя внутри виртуальной машины
    hostname    = "workstation{instance.index}"

    platform_id = "standard-v3"
    resources {
      memory = 2
      cores  = 2
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
      user-data = "${file("./cloud-init.yml")}"

      serial-port-enable = 1
    }

    scheduling_policy { preemptible = true }

    network_interface {
      network_id         = yandex_vpc_network.net_cloud01.id
      subnet_ids         = ["${yandex_vpc_subnet.block_1.id}"]
      nat                = true
    }
  }

  scale_policy {
    fixed_scale {
      size = 2 # Количество ВМ в группе
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1 # Максимальное количество ВМ в статусе RUNNING, на которое можно уменьшить целевой размер группы
    max_expansion   = 0 # Максимальное количество ВМ, на которое можно превысить целевой размер группы
  }

  # Интеграция с балансировщиком
  load_balancer {
    target_group_name = "tg01"
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
    target_group_id = yandex_compute_instance_group.vm_group_1.load_balancer.0.target_group_id

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
