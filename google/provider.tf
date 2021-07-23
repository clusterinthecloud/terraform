terraform {
  required_version = "~> 1.0"

  required_providers {
    template = {
      source = "hashicorp/template"
      version = " >= 2.2"
    }

    external = {
      source = "hashicorp/external"
      version = " >= 2.1"
    }

    local = {
      source = "hashicorp/local"
      version = " >= 2.1"
    }

    random = {
      source = "hashicorp/random"
      version = " >= 3.1"
    }

    google = {
      source = "hashicorp/google"
      version = " >= 2.10"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  region      = var.region
  zone        = var.zone
  project     = var.project
}
