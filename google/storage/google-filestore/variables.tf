variable "export_path_fs" {
  default = "shared"
}

variable "zone" {
}

variable "tier" {
  default = "STANDARD"
}

variable "network" {
  default = null
}

variable "fs_capacity" {
  default = 1024
}

variable "cluster_id" {
  default = null
}
