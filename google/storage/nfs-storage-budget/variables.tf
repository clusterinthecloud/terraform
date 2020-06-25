variable "export_path_fs" {
  default = "shared"
}

variable "zone" {
}

variable "region" {
}

variable "vpc_subnetwork" {
}

variable "project" {
}

variable "cluster_id" {
}

variable "tier" {
  default = "STANDARD"
}

variable "network" {
  default = null
}

# 100GB as a minimum for the Budget NFS filer option.  Filestore is 1TB minimum
variable "fs_capacity" {
}

# According to GCE documentation, 1vCPU allows for 2Gbps network egress cap
# This equates to a theoretical max of 200MB/s for NFS filer performance. Double that of a
# Google Cloud Filestore standard instance.
variable "nfs_budget_shape" {
}

variable "nfs_budget_image" {
}

# NFS persistent disk type (pd-ssd or pd-standard)
variable "nfs_disk_type" {
}

variable "ansible_branch" {
}

