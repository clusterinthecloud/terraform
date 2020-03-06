resource "random_pet" "cluster-suffix" {
  length = 2
  separator = "-"
  keepers = {
  }
}

locals {
  cluster_id = var.cluster_id != null ? var.cluster_id : random_pet.cluster-suffix.id
}
