data "template_file" "bootstrap-script" {
  template = file("${path.module}/../common-files/bootstrap.sh.tpl")
  vars = {
    ansible_branch = var.ansible_branch
    cloud-platform = "aws"
    fileserver-ip  = aws_efs_mount_target.shared.dns_name
  }
}

data "template_file" "startnode-yaml" {
  template = file("${path.module}/files/startnode.yaml.tpl")
  vars = {
    ansible_branch = var.ansible_branch
    region = var.region
    subnet = aws_subnet.vpc_subnetwork.id
    compute_security_group = aws_security_group.mgmt.id
    dns_zone = aws_route53_zone.cluster.name
    dns_zone_id = aws_route53_zone.cluster.zone_id
  }
}

data "local_file" "ssh_public_key" {
  filename = pathexpand(var.public_key_path)
}

data "local_file" "ssh_private_key" {
  filename = pathexpand(var.private_key_path)
}
