# AWS Information
variable "region" {
  default = "eu-west-1"
}

variable "availability_zone" {
  default = null
}

variable "efs_performance_mode" {
  default = "generalPurpose"
}

variable "efs_encrypted" {
  default = false
}

variable "management_shape" {
  default = "t3a.medium"
}

variable "public_key_path" {
}

variable "private_key_path" {
}

variable "aws_shared_credentials" {
  default = "~/.aws/credentials"
}

variable "profile" {
  default = "default"
}

variable "ansible_branch" {
  default = "centos8"
}
