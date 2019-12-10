amazon-linux-extras install -y ansible2
amazon-linux-extras install -y epel
hostnamectl set-hostname mgmt.${dns_zone}
