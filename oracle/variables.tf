variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "region" {
}

variable "compartment_ocid" {
}

variable "ssh_public_key" {
}

variable "ManagementAD" {
  description = "The AD the management node should live in."
  default     = "1"
}

variable "FilesystemAD" {
  description = "The AD the filesystem should live in."
  default     = "1"
}

variable "ManagementShape" {
  description = "The shape to use for the management node"
  default     = "VM.Standard2.1"
}

variable "ExportPathFS" {
  default = "/shared"
}

variable "ansible_branch" {
  default = "5"
}
