data "template_file" "user_data" {
  template = file("${path.module}/../common-files/bootstrap.sh.tpl")
  vars = {
    ansible_repo = var.ansible_repo
    ansible_branch = var.ansible_branch
    cluster_id = local.cluster_id
    cloud-platform = "openstack"
    fileserver-ip  = "fileserver"
    custom_block = templatefile(
      "${path.module}/files/bootstrap_custom.sh.tpl", {
        cluster_id = local.cluster_id
        ansible_repo = var.ansible_repo
        ansible_branch = var.ansible_branch
        network_id = openstack_networking_network_v2.cluster.id
        network_name = openstack_networking_network_v2.cluster.name
        security_group = openstack_networking_secgroup_v2.cluster.name
      }
    )
    mgmt_hostname: local.mgmt_hostname
    citc_keys = var.admin_public_keys
  }
}
