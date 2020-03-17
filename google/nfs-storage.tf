# create some shared storage for the compute nodes to use

#module "filestore_shared_storage" {
#  source  = "./storage/google-filestore"
#  network = google_compute_network.vpc_network.name
#  zone    = var.zone
#  cluster_id = local.cluster_id
#}

module "budget_filer_shared_storage" {
  source = "./storage/nfs-storage-budget"
  network = google_compute_network.vpc_network.name
  zone    = var.zone
  cluster_id = local.cluster_id
  region = var.region
  project = var.project
  ansible_branch = var.ansible_branch
  vpc_subnetwork = google_compute_subnetwork.vpc_subnetwork.name

  # Budget filer parameters
  fs_capacity = var.fs_capacity
  nfs_budget_shape = var.nfs_budget_shape
  nfs_budget_image = var.nfs_budget_image
  nfs_disk_type = var.nfs_disk_type
}
