output "fileserver-ip" {
  value = google_compute_instance.nfs_server_budget.network_interface[0].network_ip
}
