output "app_external_ip" {
  value = "${google_compute_instance.app.*.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "load_balancer_ip" {
  value = "${google_compute_global_address.lb-ip.address}"
}

output "load_balancer_ip2" {
  value = "${google_compute_global_forwarding_rule.reddit-app-forwarding-rule.ip_address}"
}
