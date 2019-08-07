# create some shared storage for the compute nodes to use

module "filestore_shared_storage" {
    source          = "./storage/google-filestore"
    network         = "${google_compute_network.vpc_network.name}"
    zone            = "${var.zone}"
}
