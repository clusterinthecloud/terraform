resource "google_compute_instance" "slurm-master" {
  name         = "slurm-master"
  machine_type = "${var.management_compute_instance_config["type"]}"

  tags = ["slurm-master"]

  boot_disk {
    initialize_params {
      image = "${var.management_compute_instance_config["image"]}"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.vpc_subnetwork.name}"
    access_config {}
  }

  service_account {
    email = "${google_service_account.slurm-master-sa.email}"
    scopes = ["compute-rw"]
  }
}