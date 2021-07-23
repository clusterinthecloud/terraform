locals {
  mgmt_hostname = "mgmt-${local.cluster_id}"
  # These are the user's admin keys, prepared for use with the provisioner user
  provisioner_public_keys = join("\n", [for key in split("\n", var.admin_public_keys) : "provisioner:${key}"])
}

resource "tls_private_key" "provisioner_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

# Management node instance
resource "google_compute_instance" "mgmt" {
  name                    = local.mgmt_hostname
  machine_type            = var.management_shape
  tags                    = ["mgmt-${local.cluster_id}"]
  metadata_startup_script = data.template_file.bootstrap-script.rendered

  #depends_on = [module.filestore_shared_storage, google_service_account.mgmt-sa, google_project_iam_member.mgmt-sa-computeadmin, google_project_iam_member.mgmt-sa-serviceaccountuser]
  depends_on = [module.budget_filer_shared_storage, google_service_account.mgmt-sa, google_project_iam_member.mgmt-sa-computeadmin, google_project_iam_member.mgmt-sa-serviceaccountuser]

  # add an ssh key that can be used to provision the instance once it's started
  metadata = {
    ssh-keys = "provisioner:${tls_private_key.provisioner_key.public_key_openssh}\n${local.provisioner_public_keys}"
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

  provisioner "file" {
    destination = "/tmp/startnode.yaml"
    content     = data.template_file.startnode-yaml.rendered

    connection {
      type        = "ssh"
      user        = "provisioner"
      private_key = tls_private_key.provisioner_key.private_key_pem
      host        = self.network_interface.0.access_config.0.nat_ip
    }
  }

  provisioner "file" {
    destination = "/tmp/mgmt-sa-credentials.json"
    content     = base64decode(google_service_account_key.mgmt-sa-key.private_key)

    connection {
      type        = "ssh"
      user        = "provisioner"
      private_key = tls_private_key.provisioner_key.private_key_pem
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "files/cleanup.sh"
    environment = {
      CLUSTERID = self.labels.cluster
      PROJECT = self.project
    }
    working_dir = path.module
  }
}
