data "template_file" "bootstrap-script" {
  template = file("${path.module}/../common-files/bootstrap.sh.tpl")
  vars = {
    ansible_repo = var.ansible_repo
    ansible_branch = var.ansible_branch
    cloud-platform = "aws"
    fileserver-ip  = aws_efs_mount_target.shared.dns_name
    custom_block = templatefile("${path.module}/files/bootstrap_custom.sh.tpl", {
      dns_zone = aws_route53_zone.cluster.name
    })
    mgmt_hostname: local.mgmt_hostname
    citc_keys = var.admin_public_keys
  }
}

data "template_file" "startnode-yaml" {
  template = file("${path.module}/files/startnode.yaml.tpl")
  vars = {
    cloud-platform = "aws"
    ansible_repo = var.ansible_repo
    ansible_branch = var.ansible_branch
    region = var.region
    subnet = aws_subnet.vpc_subnetwork.id
    compute_security_group = aws_security_group.mgmt.id
    dns_zone = aws_route53_zone.cluster.name
    dns_zone_id = aws_route53_zone.cluster.zone_id
    cluster_id: local.cluster_id
  }
}
