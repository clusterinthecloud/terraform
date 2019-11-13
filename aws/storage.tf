resource "aws_efs_file_system" "shared" {
  performance_mode = var.efs_performance_mode
  encrypted = var.efs_encrypted

  tags = {
    Name = "citc-shared-${var.ClusterNameTag}"
  }
}

resource "aws_efs_mount_target" "shared" {
  file_system_id = aws_efs_file_system.shared.id
  subnet_id      = aws_subnet.vpc_subnetwork.id
  security_groups = [aws_security_group.storage.id]
}

resource "aws_route53_record" "shared" {
  zone_id = aws_route53_zone.cluster.zone_id
  name    = "fileserver.${aws_route53_zone.cluster.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_efs_mount_target.shared.dns_name]
}
