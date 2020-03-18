resource "oci_core_virtual_network" "ClusterVCN" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "ClusterVCN-${local.cluster_id}"
  dns_label      = replace(local.cluster_id, "-", "")

  freeform_tags = {
    "cluster" = local.cluster_id
  }
}

resource "oci_core_subnet" "ClusterSubnet" {
  cidr_block        = "10.1.0.0/16"
  display_name      = "Subnet-${local.cluster_id}"
  dns_label         = "subnet"
  security_list_ids = [oci_core_virtual_network.ClusterVCN.default_security_list_id, oci_core_security_list.ClusterSecurityList.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.ClusterVCN.id
  route_table_id    = oci_core_route_table.ClusterRT.id
  dhcp_options_id   = oci_core_virtual_network.ClusterVCN.default_dhcp_options_id

  freeform_tags = {
    "cluster" = local.cluster_id
  }
}

resource "oci_core_internet_gateway" "ClusterIG" {
  compartment_id = var.compartment_ocid
  display_name   = "ClusterIG-${local.cluster_id}"
  vcn_id         = oci_core_virtual_network.ClusterVCN.id

  freeform_tags = {
    "cluster" = local.cluster_id
  }
}

resource "oci_core_route_table" "ClusterRT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.ClusterVCN.id
  display_name   = "ClusterRT-${local.cluster_id}"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.ClusterIG.id
  }

  freeform_tags = {
    "cluster" = local.cluster_id
  }
}

resource "oci_core_security_list" "ClusterSecurityList" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.ClusterVCN.id
  display_name   = "ClusterSecurityList-${local.cluster_id}"

  // allow inbound ssh traffic from a specific port
  ingress_security_rules {
    # Open all ports within the private network
    protocol = "6"
    source   = "10.0.0.0/8"
  }
  ingress_security_rules {
    # Open port for Grafana
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 3000
      max = 3000
    }
  }
  ingress_security_rules {
    # Open port for HTTP
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  freeform_tags = {
    "cluster" = local.cluster_id
  }
}
