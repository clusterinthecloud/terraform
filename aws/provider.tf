terraform {
  required_version = "~> 0.13"
  required_providers {
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.20"
    }
  }
}

provider "aws" {
  profile     = var.profile  # refer to ~/.aws/credentials
  region      = var.region
}
