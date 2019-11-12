# Pin the terraform and provider versions to avoid issues if the 

terraform {
  required_version = "~> 0.12"
}

provider "template" {
  version = "2.1"
}

provider "external" {
  version = "1.2"
}

provider "local" {
  version = "1.3"
}

provider "aws" {
  version     = "2.16.0"
  profile     = var.profile  # refer to ~/.aws/credentials
  region      = var.region
}
