variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable "db-disk-image" {
  description = "Disk image for reddit db"
  default     = "db-mongodb"
}

variable "user" {
  default = ["appuser", "appuser1"]
}

variable zone {
  description = "Zone"
  default     = "europe-west1-d"
}
