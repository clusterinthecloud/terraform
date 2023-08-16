data "template_file" "user_data" {
  template = file("${path.module}/../common-files/bootstrap.sh.tpl")
  vars = {
    ansible_repo = var.ansible_repo
    ansible_branch = var.ansible_branch
    cloud-platform = "oracle"
    fileserver-ip  = openstack_sharedfilesystem_share_v2.ClusterFS.host
    custom_block = templatefile("${path.module}/files/bootstrap_custom.sh.tpl", {})
    mgmt_hostname: local.mgmt_hostname
    citc_keys = ""#var.ssh_public_key
  }
}
