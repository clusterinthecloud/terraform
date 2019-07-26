region: ${var.region}
compartment_id: ${var.compartment_ocid}
vcn_id: ${oci_core_virtual_network.ClusterVCN.id}
ad_root: ${substr(oci_core_instance.ClusterManagement.availability_domain, 0, length(oci_core_instance.ClusterManagement.availability_domain)-1)}
ansible_branch: ${var.ansible_branch}