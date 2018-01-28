# Google provider settings
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_project_metadata" "ssh_keys" {
  metadata {
    ssh-keys = "appuser1:${file("~/.ssh/appuser.pub")}\nappuser2:${file(var.public_key_path)}"
  }
}

resource "google_compute_instance" "app" {
  name         = "reddit-app-${count.index}"
  count        = 2
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config {}
  }

  metadata {
    #Добавление публичного ключа к инстансу
    ssh-keys = "appuser:${file(var.public_key_path)}\nappuser1:${file(var.public_key_path)}"
  }

  #Определение подключения для provisioner
  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с тегом ...
  target_tags = ["reddit-app"]
}

#Backend service
resource "google_compute_backend_service" "backend-redditapp" {
  name        = "backend-redditapp"
  description = "Reddit-app-service"
  port_name   = "tcp9292"
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group.group.self_link}"
  }

  health_checks = ["${google_compute_http_health_check.heald-chek.self_link}"]
}

#Создание глобального внешнего IP адреса
resource "google_compute_global_address" "lb-ip" {
  name = "lb-ip"
}

resource "google_compute_instance_group" "group" {
  name        = "group"
  description = "Reddit-app"
  zone        = "${var.zone}"
  instances   = ["${google_compute_instance.app.*.self_link}"]

  named_port {
    name = "tcp9292"
    port = "9292"
  }

  #network     = "${google_compute_network.default.self_link}"
}

#проверка состояния инстранса
resource "google_compute_http_health_check" "heald-chek" {
  name               = "health-check"
  request_path       = "/"
  check_interval_sec = 3
  timeout_sec        = 3
  port               = "9292"
}

#Manages a URL Map resource within GCE
resource "google_compute_url_map" "reddit-app-url-map" {
  name            = "reddit-app-url-map"
  default_service = "${google_compute_backend_service.backend-redditapp.self_link}"
}

resource "google_compute_target_http_proxy" "http-reddit-proxy" {
  name        = "reddit-proxy"
  description = "Http proxy"
  url_map     = "${google_compute_url_map.reddit-app-url-map.self_link}"
}

#Forwarding Rule
resource "google_compute_global_forwarding_rule" "reddit-app-forwarding-rule" {
  name   = "reddit-app-forwarding-rule"
  target = "${google_compute_target_http_proxy.http-reddit-proxy.self_link}"

  #global ipaddress 
  ip_address = "${google_compute_global_address.lb-ip.address}"
  port_range = "80"
}
