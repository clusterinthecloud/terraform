# create some shared storage for the compute nodes to use

# fs_export_path    The export to assign. Default = shared
# zone              The GCP zone, required. No Default
# tier              Default = STANDARD
# network           VPC Network Name. Default = citc-net
# fs_capacity       MB of storage. Default = 1024
module "filestore_shared_storage" {
    source          = "./storage/google-filestore"
    network         = "${google_compute_network.vpc_network.name}"
    zone            = "${var.gcp_zone}"
}
