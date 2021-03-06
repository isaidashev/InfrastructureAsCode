variable "source_ranges" {
  description = "Allowed IP addresses"
  default     = ["0.0.0.0/0"]
}

variable firewall_ssh {
  description = "Name for ssh allow rule"
  default     = "default-allow-ssh"
}

variable network_name {
  description = "Name for used network"
  default     = "allow-ssh-default"
}

variable "protocol" {
  default = "tcp"
}

variable "ports" {
  description = "Port for open"
}
