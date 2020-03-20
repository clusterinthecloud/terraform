# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.compartment_ocid
}

data "tls_public_key" "oci_public_key" {
  private_key_pem = file(var.private_key_path)
}

data "template_file" "user_data" {
  template = file("${path.module}/../common-files/bootstrap.sh.tpl")
  vars = {
    ansible_branch = var.ansible_branch
    cloud-platform = "oracle"
    fileserver-ip  = oci_file_storage_mount_target.ClusterFSMountTarget.hostname_label
    custom_block = ""
    mgmt_hostname: local.mgmt_hostname
  }
}
