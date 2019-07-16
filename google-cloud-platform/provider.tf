# Pin the terraform and provider versions to avoid issues if the 

terraform {
  required_version = "0.11.13"
}

provider "google" {
  version = "2.10"
  region  = "${var.gcp_region}"
  zone    = "${var.gcp_zone}"
  project = "${var.gcp_project}"
}