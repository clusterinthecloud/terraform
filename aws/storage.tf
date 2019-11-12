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
}
