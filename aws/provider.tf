terraform {
  required_version = "~> 0.13"
  required_providers {
    template = {
      source  = "hashicorp/template"
      version = "~> 2.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 1.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 1.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.16.0"
    }
  }
}

provider "aws" {
  profile     = var.profile  # refer to ~/.aws/credentials
  region      = var.region
}
