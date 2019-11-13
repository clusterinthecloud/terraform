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
  }
}

data "local_file" "ssh_public_key" {
  filename = pathexpand(var.public_key_path)
}

data "local_file" "ssh_private_key" {
  filename = pathexpand(var.private_key_path)
}
