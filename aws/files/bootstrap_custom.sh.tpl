# This allows the user to log into the centos provisioning account
# with their provided keys. This is needed to debug if,
# for example,ansible fails to run.
cat >> /home/centos/.ssh/authorized_keys <<EOF
${citc_keys}
EOF

dnf install -y epel-release
dnf config-manager --set-enabled PowerTools
hostnamectl set-hostname mgmt.${dns_zone}
