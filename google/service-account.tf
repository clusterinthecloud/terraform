# Service account identity for the mgmt node
resource "google_service_account" "mgmt-sa" {
  account_id   = "mgmt-sa-${local.cluster_id}"
  display_name = "Management node service account"
}

# add IAM roles to the service account
resource "google_project_iam_member" "mgmt-sa-serviceaccountuser" {
  project = var.project
  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.mgmt-sa.email}"
}

resource "google_project_iam_member" "mgmt-sa-computeadmin" {
  project = var.project
  role   = "roles/compute.instanceAdmin.v1"
  member = "serviceAccount:${google_service_account.mgmt-sa.email}"
}

resource "google_service_account_key" "mgmt-sa-key" {
  service_account_id = google_service_account.mgmt-sa.name
}
