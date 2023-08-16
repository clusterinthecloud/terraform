resource "random_pet" "cluster-suffix" {
  length = 2
  separator = "-"
  keepers = {
  }
}

locals {
  cluster_id = random_pet.cluster-suffix.id
}
