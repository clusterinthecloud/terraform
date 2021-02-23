data "template_file" "bootstrap-script" {
  template = file("${path.module}/../common-files/bootstrap.sh.tpl")
  vars = {
    ansible_repo = var.ansible_repo
    ansible_branch = var.ansible_branch
    cloud-platform = "google"
    fileserver-ip  = module.budget_filer_shared_storage.fileserver-ip
    #fileserver-ip  = module.filestore_shared_storage.fileserver-ip
    custom_block = templatefile("${path.module}/files/bootstrap_custom.sh.tpl", {})
    mgmt_hostname: local.mgmt_hostname
    citc_keys = var.admin_public_keys
  }
}

data "template_file" "startnode-yaml" {
  template = file("${path.module}/files/startnode.yaml.tpl")
  vars = {
    cloud-platform = "google"
    project        = var.project
    zone           = var.zone
    subnet         = "regions/${var.region}/subnetworks/${google_compute_subnetwork.vpc_subnetwork.name}"
    network_name    = google_compute_network.vpc_network.name
    subnet_name    = google_compute_subnetwork.vpc_subnetwork.name
    ansible_repo = var.ansible_repo
    ansible_branch = var.ansible_branch
    custom_block = ""
    cluster_id: local.cluster_id
  }
}
