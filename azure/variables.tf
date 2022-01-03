locals {
  admin_username = "centos"
  mgmt_hostname = "mgmt"
}

variable "region" {
  default = "westeurope"
}

variable "admin_public_keys" {
  type = string
  description = "A multiline string containing the public keys used to login as the admin user"
}

variable "ansible_repo" {
  default = "https://github.com/hmeiland/ansible.git"
}

variable "ansible_branch" {
  default = "feature-azure"
}
