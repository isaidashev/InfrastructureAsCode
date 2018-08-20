output "app_external_ip" {
  value = "${google_compute_instance.gitlab-ci.app_external_ip}"
}
