locals {
  mgmt_hostname = "mgmt-${local.cluster_id}"
}

# Management node instance
resource "google_compute_instance" "mgmt" {
  name                    = local.mgmt_hostname
  machine_type            = var.management_shape
  tags                    = ["mgmt-${local.cluster_id}"]
  metadata_startup_script = data.template_file.bootstrap-script.rendered

  #depends_on = [module.filestore_shared_storage]
  depends_on = [module.budget_filer_shared_storage]

  # add an ssh key that can be used to provision the instance once it's started
  metadata = {
    ssh-keys = "provisioner:${file("citc-provisioning-key-google.pub").content}"
  }

  boot_disk {
    initialize_params {
      image = var.management_image
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.vpc_subnetwork.name

    # add an empty access_config block. We only need a public address which is a default part of this block
    access_config {
    }
  }

  # Ignore changes to the disk image, as if a family is specified it != the image name on the instance, and continually
  # rebuild when terraform is reapplied
  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image]
  }

  labels = {
    cluster = local.cluster_id
  }

  # ssh connection information for provisioning
  connection {
    type        = "ssh"
    user        = "provisioner"
    private_key = file("citc-provisioning-key-google")
    host        = self.network_interface[0].access_config[0].nat_ip
  }

  provisioner "file" {
    destination = "/tmp/shapes.yaml"
    source      = "${path.module}/files/shapes.yaml"
  }

  provisioner "file" {
    destination = "/tmp/startnode.yaml"
    content     = data.template_file.startnode-yaml.rendered
  }

  provisioner "file" {
    destination = "/tmp/mgmt-sa-credentials.json"
    content     = base64decode(google_service_account_key.mgmt-sa-key.private_key)
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo -u citc /usr/local/bin/kill_all_nodes --force",
      "sudo -u citc /usr/local/bin/cleanup_images --force",
    ]
  }
}
