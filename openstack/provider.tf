terraform {
  required_version = ">= 1.0"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "~> 1.48"
    }
  }
}

provider openstack {
  cloud = "openstack"
  tenant_name = "demo"
}
