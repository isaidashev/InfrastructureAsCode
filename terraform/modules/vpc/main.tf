resource "google_compute_firewall" "firewall_ssh" {
  description = "My Describtion"
  name        = "${var.name_rule}"

  # Название сети, в которой действует правило
  network = "${var.network_name}"

  # Какой доступ разрешить
  allow {
    protocol = "${var.protocol}"
    ports    = ["${var.ports}"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = "${var.source_ranges}"

  # Правило применимо для инстансов с тегом ...
  #target_tags = ["ssh"]
}
