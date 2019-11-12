resource "aws_security_group" "mgmt" {
  name        = "citc-mgmt-${var.ClusterNameTag}"
  description = "Management node"
  vpc_id      = "${aws_vpc.vpc_network.id}"

  ingress {
    from_port   = 22
    to_port     = 22
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
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "citc-mgmt-${var.ClusterNameTag}"
  }
}

resource "aws_security_group" "compute" {
  name        = "citc-compute-${var.ClusterNameTag}"
  description = "Compute node"
  vpc_id      = "${aws_vpc.vpc_network.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "citc-compute-${var.ClusterNameTag}"
  }
}

