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

    null = {
      source = "hashicorp/null"
      version = " >= 3.1"
    }

    aws = {
      source = "hashicorp/aws"
      version = " >= 3.51.0"
    }
  }
}

provider "aws" {
  profile     = var.profile  # refer to ~/.aws/credentials
  region      = var.region
}
