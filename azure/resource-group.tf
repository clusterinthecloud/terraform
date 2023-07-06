resource "azurerm_resource_group" "rg" {
  name     = "citc-${local.cluster_id}"
  location = "${var.region}"

  lifecycle {
    ignore_changes = [
      tags["CreatedOn"]
    ]
  }
}
