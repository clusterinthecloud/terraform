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

provider "random" {
  version = "~> 2.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "aws" {
  version     = "3.30.0"
  profile     = var.profile  # refer to ~/.aws/credentials
  region      = var.region
}
