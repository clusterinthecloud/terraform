variable "admin_public_keys" {
  type = string
  nullable = false
  sensitive = false
}

variable "mgmt_flavor" {
  default = "m1.medium"
  type = string
  nullable = false
  sensitive = false
}

variable "external_network_name" {
  default = "external"
  type = string
  nullable = false
  sensitive = false
}

variable "ansible_repo" {
  default = "https://github.com/clusterinthecloud/ansible.git"
  type = string
  nullable = false
  sensitive = false
}

variable "ansible_branch" {
  default = "6"
  type = string
  nullable = false
  sensitive = false
}
