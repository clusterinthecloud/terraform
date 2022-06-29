# This allows the user to log into the rocky provisioning account
# with their provided keys. This is needed to debug if,
# for example,ansible fails to run.
cat >> /home/rocky/.ssh/authorized_keys <<EOF
${citc_keys}
EOF

dnf install -y epel-release
dnf config-manager --set-enabled powertools
hostnamectl set-hostname mgmt.${dns_zone}
