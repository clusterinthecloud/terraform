output "ManagementPublicIPs" {
  value = ["${oci_core_instance.ClusterManagement.*.public_ip}"]
}
