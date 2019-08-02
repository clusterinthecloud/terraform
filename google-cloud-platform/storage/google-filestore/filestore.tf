resource "google_filestore_instance" "instance" {
  name = "citc-filer"
  zone = "${var.zone}"
  tier = "${var.tier}"

  file_shares {
    capacity_gb = "${var.fs_capacity}"
    name        = "${var.export_path_fs}"
  }

  networks {
    network = "${var.network}"
    modes   = ["MODE_IPV4"]
  }
}
