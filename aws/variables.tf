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

variable "admin_public_keys" {
  type = string
  description = "A multiline string containing the public keys used to login as the admin user"
}

variable "aws_shared_credentials" {
  default = "~/.aws/credentials"
}

variable "profile" {
  default = "default"
}

variable "ansible_repo" {
  default = "https://github.com/clusterinthecloud/ansible.git"
}

variable "ansible_branch" {
  default = "6"
}
