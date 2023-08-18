data "template_file" "user_data" {
  template = file("${path.module}/../common-files/bootstrap.sh.tpl")
  vars = {
    ansible_repo = var.ansible_repo
    ansible_branch = var.ansible_branch
    cluster_id = local.cluster_id
    cloud-platform = "openstack"
    fileserver-ip  = "mgmt"  # TODO openstack_sharedfilesystem_share_v2.ClusterFS.host
    custom_block = templatefile(
      "${path.module}/files/bootstrap_custom.sh.tpl", {
        cluster_id = local.cluster_id
        ansible_repo = var.ansible_repo
        ansible_branch = var.ansible_branch
      }
    )
    mgmt_hostname: local.mgmt_hostname
    citc_keys = var.ssh_public_key
  }
}
