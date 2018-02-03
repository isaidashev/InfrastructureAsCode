variable source_ranges {
  description = "Allowed IP addresses"
  default     = ["0.0.0.0/0"]
}

variable name_rule {
  description = "Name for ssh allow rule"
  default     = "default-allow-addres"
}

variable network_name {
  description = "Name for used network"
  default     = "default"
}

variable "protocol" {
  default = "tcp"
}

variable ports {
  description = "Port for open"
}
