terraform {
  required_version = "~> 0.14"
}

provider "template" {
  version = "~> 2"
}

provider "tls" {
  version = "~> 3"
}

provider "random" {
  version = "~> 2"
}

provider "oci" {
  version          = ">= 4.14.0"

  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
