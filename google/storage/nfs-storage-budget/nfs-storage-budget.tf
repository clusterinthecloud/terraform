resource "google_compute_disk" "nfsshare" {
  name = "nfsshare"
  type = var.nfs_disk_type

  labels = {
    cluster = var.cluster_id
  }

  size = var.fs_capacity 
} 

data "template_file" "nfs-script" {
  template = file("${path.module}/files/nfsconfig.sh.tpl")
  vars = {
    ansible_branch = var.ansible_branch
    cloud-platform = "google"
    custom_block = ""
    cluster_id = var.cluster_id
  }
}

resource "google_compute_firewall" "ssh-nfs" {
  name          = "ssh-to-nfs-${var.cluster_id}"
  network       = var.network
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["nfs-${var.cluster_id}"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_instance" "nfs_server_budget" {
  name                      = "nfs-filer-${var.cluster_id}"
  machine_type              = var.nfs_budget_shape
  tags                      = ["nfs-${var.cluster_id}"]
  metadata_startup_script   = data.template_file.nfs-script.rendered
  depends_on                = [google_compute_disk.nfsshare]

  boot_disk {
    initialize_params {
      image = var.nfs_budget_image
    }
  }

  # Keep the primary NFS volume separate from the boot disk so it can be backed up
  # and snapshots taken independently from the boot disk
  attached_disk {
    source = "nfsshare"
  }

  network_interface {
    subnetwork = var.vpc_subnetwork
    
    # add an empty access_config block. We only need a public address which is a default part of this block
    access_config {
    }
  }

  labels = {
    cluster = var.cluster_id
  }
}
