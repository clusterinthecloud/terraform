variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {}
variable "ssh_public_key" {}

variable "ADS" {
  description = "The list of ADs you want to create your cluster across."
  default = ["1", "2", "3"]
}

variable "ManagementAD" {
  description = "The AD the management node should live in."
  default = "1"
}

variable "FilesystemAD" {
  description = "The AD the filesystem should live in."
  default = "1"
}

variable "ManagementShape" {
  description = "The shape to use for the management node"
  default = "VM.Standard1.2"
}

variable "ManagementImageOCID" {
  description = "What image to use for the management node. A map of region name to image OCID."
  type = "map"

  default = {
    // See https://docs.cloud.oracle.com/iaas/images/
    // CentOS-7.5-2018.05.11-0
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaabsyrkaz5dwyd2szcgo6fnxi5btvoizpnbpdxpxtl7bpqckqpo4cq"
    uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaavlnwnzmzsezk7gae3ncxmy67fkmks5cw7indrymrv3phic2ddlzq"
  }
}

variable "BootStrapFile" {
  default = "./userdata/bootstrap"
}

variable "ExportPathFS" {
  default = "/shared"
}

variable "ClusterNameTag" {
  default = "cluster"
}

variable "ansible_branch" {
  default = "master"
}
