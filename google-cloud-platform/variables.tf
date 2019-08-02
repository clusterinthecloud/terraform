# Google Cloud Platform Information
variable "gcp_region"                         {}
variable "gcp_project"                        {}
variable "gcp_zone"                           {}

variable "credentials"                        {}

# Networking
variable "network_ipv4_cidr"                  {}

# Storage
variable "export_path_fs"                     {default = "shared"}
variable "storage_size_mb"                    {default = 1024}

# Slurm Cluster
variable "cluster_name_tag"                   {}
variable "management_compute_instance_config" {
  default = {
    type            = "n1-standard-1",
    image           = "centos-cloud/centos-7"
    ansible_branch  = 3
  }
}
variable "private_key_path"                     {}
variable "public_key_path"                      {}