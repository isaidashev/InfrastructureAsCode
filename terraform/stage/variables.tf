variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable "db-disk-image" {
  description = "Disk image for reddit db"
  default     = "db-mongodb"
}

variable "app-disk-image" {
  description = "Disk image for reddit app"
  default     = "app-ruby"
}

variable private_key {
  description = "Path to private key for provisioner"
}

variable "user" {
  default = ["appuser", "appuser1"]
}

variable zone {
  description = "Zone"
  default     = "europe-west1-d"
}
