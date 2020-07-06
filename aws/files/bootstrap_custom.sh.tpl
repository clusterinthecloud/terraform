dnf install -y epel-release
dnf config-manager --set-enabled PowerTools
hostnamectl set-hostname mgmt.${dns_zone}
