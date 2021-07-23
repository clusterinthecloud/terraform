terraform {
  required_version = "~> 1.0"

  required_providers {
    template = {
      source = "hashicorp/template"
      version = " >= 2.2"
    }

    tls = {
      source = "hashicorp/tls"
      version = " >= 3.1"
    }

    random = {
      source = "hashicorp/random"
      version = " >= 3.1"
    }

    oci = {
      source = "hashicorp/oci"
      version = " >= 4.36.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
