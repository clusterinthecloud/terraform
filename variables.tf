variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {}
variable "ssh_public_key" {}

variable "ADS" {
  description = "The list of ADs you want to create your cluster across."
  default = ["1"]
}

variable "ManagementAD" {
  description = "The AD the management node should live in."
  default = "1"
}

variable "FilesystemAD" {
  description = "The AD the filesystem should live in."
  default = "1"
}

variable "InstanceADIndex" {
  description = "A list of AD numbers that the compute nodes shuold be mae in. Repeat an index to create multiple instances in an AD."
  type    = "list"
  default = ["1", "3"]
}

variable "ManagementShape" {
  description = "The shape to use for the management node"
  default = "VM.Standard1.2"
}

variable "ComputeShapes" {
  description = "The list of shapes to use for the compute nodes. Maps to `InstanceADIndex`."
  type    = "list"
  default = ["VM.Standard1.2", "VM.Standard1.2"]
}

variable "ManagementImageOCID" {
  description = "What image to use for the management node. A map of region name to image OCID."
  type = "map"

  default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
    // CentOS-7.5-2018.05.11-0
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaabsyrkaz5dwyd2szcgo6fnxi5btvoizpnbpdxpxtl7bpqckqpo4cq"
    uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaavlnwnzmzsezk7gae3ncxmy67fkmks5cw7indrymrv3phic2ddlzq"
  }
}

variable "ComputeImageOCID" {
  description = "What images to use for the compute node shapes. A map of shape name to a map of region to image OCID."
  type = "map"

  default = {
    VM.Standard1.2 = {
      // See https://docs.us-phoenix-1.oraclecloud.com/images/
      // CentOS-7.5-2018.05.11-0
      eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaabsyrkaz5dwyd2szcgo6fnxi5btvoizpnbpdxpxtl7bpqckqpo4cq"
      uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaavlnwnzmzsezk7gae3ncxmy67fkmks5cw7indrymrv3phic2ddlzq"
    }
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
