# Create the network to host Slurm
resource "aws_vpc" "vpc_network" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  tags = {
    Name = "citc-net-${local.cluster_id}"
    cluster = local.cluster_id
  }
}

resource "aws_subnet" "vpc_subnetwork" {
  vpc_id     = aws_vpc.vpc_network.id
  cidr_block = "10.0.0.0/17"
  tags = {
    Name = "citc-subnet-${local.cluster_id}"
    cluster = local.cluster_id
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_network.id

  tags = {
    Name = "citc-gw-${local.cluster_id}"
    cluster = local.cluster_id
  }
}

resource "aws_route" "internet_route" {
  route_table_id            = aws_vpc.vpc_network.main_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.gw.id
}
