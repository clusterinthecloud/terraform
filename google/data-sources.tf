data "local_file" "ssh_private_key" {
  filename = pathexpand(var.private_key_path)
}

data "local_file" "ssh_public_key" {
  filename = pathexpand(var.public_key_path)
}

data "template_file" "bootstrap-script" {
  template = file("${path.module}/../common-files/bootstrap.sh.tpl")
  vars = {
    ansible_branch = var.ansible_branch
    cloud-platform = "google"
    fileserver-ip  = module.budget_filer_shared_storage.fileserver-ip
    #fileserver-ip  = module.filestore_shared_storage.fileserver-ip
    custom_block = ""
    cluster_id: local.cluster_id
    mgmt_hostname: local.mgmt_hostname
  }
}

data "template_file" "startnode-yaml" {
  template = file("${path.module}/files/startnode.yaml.tpl")
  vars = {
    cloud-platform = "google"
    project        = var.project
    zone           = var.zone
    subnet         = "regions/${var.region}/subnetworks/${google_compute_subnetwork.vpc_subnetwork.name}"
    ansible_branch = var.ansible_branch
    custom_block = ""
    cluster_id: local.cluster_id
  }
}
