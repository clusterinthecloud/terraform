# Google Cloud Platform Information
gcp_region                          = "europe-west4"
gcp_project                         = "ex-eccoe-university-bristol"
gcp_zone                            = "europe-west4-a"
network_ipv4_cidr                   = "10.1.0.0/16"

cluster_name_tag                    = "mycluster"
private_key_path                    = "/home/vagrant/.ssh/google_compute_engine"
public_key_path                     = "/home/vagrant/.ssh/google_compute_engine.pub"

management_compute_instance_config = {
    type  = "n1-standard-1",
    image = "centos-cloud/centos-7"
}