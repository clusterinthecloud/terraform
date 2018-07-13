resource "oci_core_virtual_network" "ClusterVCN" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "ClusterVCN"
  dns_label      = "clustervcn"
}

resource "oci_core_subnet" "ClusterSubnet" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  cidr_block          = "10.1.20.0/24"
  display_name        = "ClusterSubnet"
  dns_label           = "clustersubnet"
  security_list_ids   = ["${oci_core_virtual_network.ClusterVCN.default_security_list_id}", "${oci_core_security_list.ClusterSecurityList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.ClusterVCN.id}"
  route_table_id      = "${oci_core_route_table.ClusterRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.ClusterVCN.default_dhcp_options_id}"
}

resource "oci_core_internet_gateway" "ClusterIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "ClusterIG"
  vcn_id         = "${oci_core_virtual_network.ClusterVCN.id}"
}

resource "oci_core_route_table" "ClusterRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.ClusterVCN.id}"
  display_name   = "ClusterRT"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.ClusterIG.id}"
  }
}

resource "oci_core_security_list" "ClusterSecurityList" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.ClusterVCN.id}"
  display_name   = "ClusterSecurityList"

  // allow inbound ssh traffic from a specific port
  ingress_security_rules = [
    {
      # Slurm
      protocol = "6"
      source   = "10.0.0.0/8"

      tcp_options {
        min = 6817
        max = 6818
      }
    },
    {
      # Next three are for file system
      protocol = "6"
      source   = "10.0.0.0/8"

      tcp_options {
        "min" = 2048
        "max" = 2050
      }
    },
    {
      protocol = "6"
      source   = "10.0.0.0/8"

      tcp_options {
        source_port_range {
          "min" = 2048
          "max" = 2050
        }
      }
    },
    {
      protocol = "6"
      source   = "10.0.0.0/8"

      tcp_options {
        "min" = 111
        "max" = 111
      }
    },
  ]
}
