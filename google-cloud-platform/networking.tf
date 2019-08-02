# Create the network to host Slurm
resource "google_compute_network" "vpc_network" {
  name                          = "slurm-cluster-net"
  auto_create_subnetworks       = "false"
}
resource "google_compute_subnetwork" "vpc_subnetwork" {
  name              = "slurm-cluster-subnet"
  ip_cidr_range     = "${var.network_ipv4_cidr}"
  network           = "${google_compute_network.vpc_network.self_link}"
}

# Add some firewall rules
resource "google_compute_firewall" "slurm-nodes" {
  name              = "slurm-nodes-to-master"
  network           = "${google_compute_network.vpc_network.name}"
  source_ranges     = ["${var.network_ipv4_cidr}"]
  target_tags       = ["slurm-master"]
  allow {
    protocol        = "tcp"
  }
}
resource "google_compute_firewall" "grafana" {
  name              = "grafana-to-slurm-master"
  network           = "${google_compute_network.vpc_network.name}"
  source_ranges     = ["0.0.0.0/0"]
  target_tags       = ["slurm-master"]
  allow {
    protocol        = "tcp"
    ports           = ["3000"]
  }
}

resource "google_compute_firewall" "ssh" {
  name              = "ssh-to-slurm-master"
  network           = "${google_compute_network.vpc_network.name}"
  source_ranges     = ["0.0.0.0/0"]
  target_tags       = ["slurm-master"]
  allow {
    protocol        = "tcp"
    ports           = ["22"]
  }
}
