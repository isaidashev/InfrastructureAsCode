# Google provider settings
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  source          = "../modules/app"
  public_key_path = "${var.public_key_path}"

  #private_key_path = "${var.private_key_path}"
  zone           = "${var.zone}"
  app-disk-image = "${var.app-disk-image}"
}

module "db" {
  source          = "../modules/db"
  public_key_path = "${var.public_key_path}"
  zone            = "${var.zone}"
  db-disk-image   = "${var.db-disk-image}"
}

module "vpc" {
  source   = "../modules/vpc"
  protocol = "tcp"
  ports    = "22"

  #allow ip adress throw modules

  source_ranges = ["93.157.234.154/32"]
}

module "vpc2" {
  name_rule = "http-allow"
  source    = "../modules/vpc"
  protocol  = "tcp"
  ports     = "80"

  #allow ip adress throw modules

  source_ranges = ["93.157.234.154/32"]
}
