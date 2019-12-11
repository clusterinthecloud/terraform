# AWS Information
variable "region" {
  default = "eu-west-1"
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

variable "profile" {
  default = "default"
}

variable "public_key_path" {
}

variable "private_key_path" {
}

variable "ansible_branch" {
  default = "4"
}

variable "ClusterNameTag" {
  default = "cluster"
}

variable "aws_shared_credentials" {
  default = "~/.aws/credentials"
}
