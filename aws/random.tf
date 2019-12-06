resource "random_pet" "cluster-suffix" {
  length = 2
  separator = "-"
  keepers = {
  }
}

locals {
  cluster_id = "${var.ClusterNameTag}-${random_pet.cluster-suffix.id}"
}

