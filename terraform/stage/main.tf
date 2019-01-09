#Google provider settings
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

# При использовании переменых не работает удаленый state
terraform {
  backend "gcs" {
    project = "famous-buckeye-215911"
    bucket  = "stage_state"
    region  = "europe-west1"
    path    = "stage/terraform.tfstate"
  }
}

module "s3_bucket" {
  source      = "git::https://github.com/SweetOps/terraform-google-storage-bucket.git?ref=master"
  name        = ["stage_state"]
  default_acl = "publicreadwrite"
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
  source_ranges = ["0.0.0.0/0"]
}

module "vpc2" {
  name_rule = "http-allow"
  source    = "../modules/vpc"
  protocol  = "tcp"
  ports     = "80"

  #allow ip adress throw modules

  source_ranges = ["0.0.0.0/0"]
}
