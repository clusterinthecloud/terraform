resource "aws_security_group" "mgmt" {
  name        = "citc-mgmt-${local.cluster_id}"
  description = "Management node"
  vpc_id      = aws_vpc.vpc_network.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc_network.cidr_block]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "citc-mgmt-${local.cluster_id}"
    cluster = local.cluster_id
  }
}

resource "aws_security_group" "compute" {
  name        = "citc-compute-${local.cluster_id}"
  description = "Compute node"
  vpc_id      = aws_vpc.vpc_network.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc_network.cidr_block]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "citc-compute-${local.cluster_id}"
    cluster = local.cluster_id
  }
}

resource "aws_security_group" "storage" {
  name        = "citc-storage-${local.cluster_id}"
  description = "Storage system"
  vpc_id      = aws_vpc.vpc_network.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc_network.cidr_block]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "citc-storage-${local.cluster_id}"
    cluster = local.cluster_id
  }
}

