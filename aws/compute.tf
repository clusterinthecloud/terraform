data "aws_ami" "amazonlinux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*x86_64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "mgmt" {
  ami           = data.aws_ami.amazonlinux2.id
  instance_type = var.management_shape
  vpc_security_group_ids = aws_security_group.mgmt.id
  subnet_id = aws_subnet.vpc_subnetwork.id
  associate_public_ip_address = "true"

  user_data = data.template_file.bootstrap-script.rendered

  depends_on = [aws_efs_mount_target.shared]

  #TODO Upload config files

  tags = {
    Name = "mgmt"
  }
}

resource "aws_key_pair" "ec2-user" {
  key_name   = "ec2-user"
  public_key = data.local_file.ssh_public_key.content
}

