resource "aws_route53_zone" "cluster" {
  name = "${var.ClusterNameTag}.citc.local."

  vpc {
    vpc_id = "${aws_vpc.vpc_network.id}"
  }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name = aws_route53_zone.cluster.name
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.vpc_network.id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}
