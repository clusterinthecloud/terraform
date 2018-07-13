variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {}
variable "ssh_public_key" {}

variable "ADS" {
  default = ["1"]
}

variable "ManagementAD" {
  default = "1"
}

variable "FilesystemAD" {
  default = "1"
}

variable "InstanceADIndex" {
  type    = "list"
  default = ["1", "3"]
}

variable "ManagementShape" {
  default = "VM.Standard1.2"
}

variable "ComputeShape" {
  default = "VM.Standard1.2"
}

variable "ManagementImageOCID" {
  type = "map"

  default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
    // CentOS-7.5-2018.05.11-0
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaabsyrkaz5dwyd2szcgo6fnxi5btvoizpnbpdxpxtl7bpqckqpo4cq"

    uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaavlnwnzmzsezk7gae3ncxmy67fkmks5cw7indrymrv3phic2ddlzq"
  }
}

variable "ComputeImageOCID" {
  type = "map"

  default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
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
