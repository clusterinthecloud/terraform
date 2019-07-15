resource "google_filestore_instance" "instance" {
  name = "slurm-filer"
  zone = "${var.zone}"
  tier = "${var.tier}"

  file_shares {
    capacity_gb = "${var.fs_capacity}"
    name        = "${var.ExportPathFS}"
  }

  networks {
    network = "${var.slurm_network}"
    modes   = ["MODE_IPV4"]
  }
}
