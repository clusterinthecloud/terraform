# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

#data "oci_core_private_ips" IPClusterFSMountTarget {
#  count     = "${length(var.ADS)}"
#  subnet_id = "${oci_file_storage_mount_target.ClusterFSMountTarget.*.subnet_id[count.index]}"
#
#  filter {
#    name   = "id"
#    values = ["${oci_file_storage_mount_target.ClusterFSMountTarget.*.private_ip_ids[count.index]}"]
#  }
#}

data "tls_public_key" "oci_public_key" {
  private_key_pem = "${file(var.private_key_path)}"
}

data "template_file" "user_data" {
  template = "${file(var.BootStrapFile)}"

  vars {
    ansible_branch = "${var.ansible_branch}"
    compartment_ocid = "${var.compartment_ocid}"
  }
}
