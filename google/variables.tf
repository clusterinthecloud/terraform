# Google Cloud Platform Information
variable "region" {
}

variable "project" {
}

variable "zone" {
}

variable "credentials" {
}

# Networking
variable "network_ipv4_cidr" {
  default = "10.1.0.0/16"
}

# Storage
variable "export_path_fs" {
  default = "shared"
}

variable "storage_size_mb" {
  default = 1024
}

variable "cluster_id" {
  default = null
}

variable "management_shape" {
  default = "n1-standard-1"
}

variable "management_image" {
  default = "centos-cloud/centos-7"
}

variable "ansible_branch" {
  default = "google_packer"
}

variable "private_key_path" {
}

variable "public_key_path" {
}
