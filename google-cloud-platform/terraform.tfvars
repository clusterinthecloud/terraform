# Google Cloud Platform Information
gcp_region                          = "europe-west4"
gcp_project                         = "ex-eccoe-university-bristol"
gcp_zone                            = "europe-west4-a"
network_ipv4_cidr                   = "192.168.0.0/24"

cluster_name_tag                    = "mycluster"
management_compute_instance_config = {
    type  = "n1-standard-1",
    image = "debian-cloud/debian-9"
}

### Public keys used for the "oci" user on the instance
ssh_public_key = <<EOF
ssh-rsa UmFuZG9tIGtleSBjb250ZW50cy4gUHV0IHlvdXIgb3duIGtleSBpbiBoZXJlIG9idmlvdXNseS4= user@computer
ssh-rsa QW5vdGhlciByYW5kb20ga2V5IGNvbnRlbnRzLiBQdXQgeW91ciBvd24ga2V5IGluIGhlcmUgb2J2aW91c2x5Lg== user@anothercomputer
EOF
