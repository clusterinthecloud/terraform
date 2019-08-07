output "ManagementPublicIP" {
  value = "${google_compute_instance.mgmt.network_interface.0.access_config.0.nat_ip}"
}
