# Service account identity for the slurm master
resource "google_service_account" "slurm-master-sa" {
  account_id        = "${var.cluster_name_tag}-slurm-master-sa"
  display_name      = "Slurm Master Servie Account"
}

# add IAM roles to the service account
resource "google_project_iam_member" "slurm-master-sa-serviceaccountuser" {
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.slurm-master-sa.email}"
}
resource "google_project_iam_member" "slurm-master-sa-computeadmin" {
  role               = "roles/compute.instanceAdmin.v1"
  member             = "serviceAccount:${google_service_account.slurm-master-sa.email}"
}