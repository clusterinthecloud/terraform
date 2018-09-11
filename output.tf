# Output the private and public IPs of the instance
#output "ComputePrivateIPs" {
#  value = ["${oci_core_instance.ClusterCompute.*.private_ip}"]
#}

output "ComputeHostnames" {
  value = ["${oci_core_instance.ClusterCompute.*.display_name}"]
}

output "ComputePublicIPs" {
  value = ["${oci_core_instance.ClusterCompute.*.public_ip}"]
}

# Output the boot volume IDs of the instance
#output "BootVolumeIDs" {
#  value = ["${oci_core_instance.ClusterCompute.*.boot_volume_id}"]
#}

# Output the private and public IPs of the instance
#output "ManagementPrivateIPs" {
#  value = ["${oci_core_instance.ClusterManagement.*.private_ip}"]
#}

output "ManagementHostnames" {
  value = ["${oci_core_instance.ClusterManagement.*.display_name}"]
}

output "ManagementPublicIPs" {
  value = ["${oci_core_instance.ClusterManagement.*.public_ip}"]
}

#output "FSMountTargetIP" {
#  value = ["${data.oci_core_private_ips.IPClusterFSMountTarget.*.private_ips}"]
#}

#output "FSMountPoint" {
#  value = ["${var.ExportPathFS}"]
#}
