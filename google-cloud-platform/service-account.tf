# Service account identity for the mgmt node
resource "google_service_account" "mgmt-sa" {
  account_id        = "${var.cluster_name_tag}-mgmt-sa"
  display_name      = "Management node service account"
}

# add IAM roles to the service account
resource "google_project_iam_member" "mgmt-sa-serviceaccountuser" {
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.mgmt-sa.email}"
}
resource "google_project_iam_member" "mgmt-sa-computeadmin" {
  role               = "roles/compute.instanceAdmin.v1"
  member             = "serviceAccount:${google_service_account.mgmt-sa.email}"
}
