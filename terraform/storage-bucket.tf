provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.1.1"
  name    = ["storage-bucket-test-345-isaidashev", "storage-bucket-test2-745-isaidashev"]
}

output storage-bucket_url {
  value = "${module.storage-bucket.url}"
}
