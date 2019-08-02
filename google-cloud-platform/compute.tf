# Slurm Master Compute Instance
resource "google_compute_instance" "slurm-master" {
  name         = "slurm-master"
  machine_type = "${var.management_compute_instance_config["type"]}"
  tags = ["slurm-master"]
  metadata_startup_script = "${data.template_file.bootstrap-script.rendered}"

  # add an ssh key that ca be used to provisiont the instance once it's started  
  metadata = {
   ssh-keys = "provisioner:${data.local_file.ssh_public_key.content}"
 }

  boot_disk {
    initialize_params {
      image = "${var.management_compute_instance_config["image"]}"
    }
  }
  network_interface {
    subnetwork = "${google_compute_subnetwork.vpc_subnetwork.name}"

    # add an empty access_config block. We only need a public address which is a default part of this block
    access_config {}
  }

  # use the service account created to run the instance. This allows granular control over what the instance can access on GCP
  service_account {
    email = "${google_service_account.slurm-master-sa.email}"
    scopes = ["compute-rw"]
  }
  
  # Ignore changes to the disk image, as if a family is specified it != the image name on the instance, and continually
  # rebuild when terraform is reapplied
  lifecycle {
    ignore_changes = ["boot_disk.0.initialize_params.0.image"]
  }

  # ssh connection information for provisioning
  connection {
    type          = "ssh"
    user          = "provisioner"
    private_key   = "${file("${var.private_key_path}")}"
    host          = "${google_compute_instance.slurm-master.network_interface.0.access_config.0.nat_ip}"
  }

  provisioner "file" {
    destination = "/tmp/shapes.yaml"
    source = "${path.module}/files/shapes.yaml"
  }


# #keep - speak to DY about file structure
#   provisioner "file" {
#     destination = "/home/opc/startnode.yaml"
#     content = <<EOF
# region: ${var.region}
# compartment_id: ${var.compartment_ocid}
# vcn_id: ${oci_core_virtual_network.ClusterVCN.id}
# ad_root: ${substr(oci_core_instance.ClusterManagement.availability_domain, 0, length(oci_core_instance.ClusterManagement.availability_domain)-1)}
# ansible_branch: ${var.ansible_branch}
# EOF

#     connection {
#       timeout = "15m"
#       host = "${oci_core_instance.ClusterManagement.public_ip}"
#       user = "opc"
#       private_key = "${file(var.private_key_path)}"
#       agent = false
#     }
#   }

# #keep
#   provisioner "remote-exec" {
#     when = "destroy"
#     inline = [
#       "echo Terminating any remaining compute nodes",
#       "if systemctl status slurmctld >> /dev/null; then",
#       "sudo -u slurm /usr/local/bin/stopnode \"$(sinfo --noheader --Format=nodelist:10000 | tr -d '[:space:]')\" || true",
#       "fi",
#       "sleep 5",
#       "echo Node termination request completed",
#     ]

#     connection {
#         timeout = "15m"
#         host = "${oci_core_instance.ClusterManagement.public_ip}"
#         user = "opc"
#         private_key = "${file(var.private_key_path)}"
#         agent = false
#     }
#   }



}