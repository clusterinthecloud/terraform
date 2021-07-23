# Google Cloud Platform Information
variable "region" {
}

variable "project" {
}

variable "zone" {
}

variable "credentials" {
}

# NFS - Budget Filer section.

# 100GB as a minimum for the Budget NFS filer option.  Filestore is 1TB minimum
variable "fs_capacity" {
  default = 100
}

# According to GCE documentation, 1vCPU allows for 2Gbps network egress cap
# This equates to a theoretical max of 200MB/s for NFS filer performance. Double that of a
# Google Cloud Filestore standard instance.
variable "nfs_budget_shape" {
  default = "n1-standard-1"
}

variable "nfs_budget_image" {
  default = "centos-cloud/centos-8"
}

# NFS persistent disk type (pd-ssd or pd-standard)
variable "nfs_disk_type" {
  default = "pd-standard"
}

# end-of NFS - Budget Filer section.

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
  default = "centos-cloud/centos-8"
}

variable "ansible_repo" {
  default = "https://github.com/clusterinthecloud/ansible.git"
}

variable "ansible_branch" {
  default = "6"
}

variable "admin_public_keys" {
  type = string
  description = "A multiline string containing the public keys used to login as the admin user"
}
