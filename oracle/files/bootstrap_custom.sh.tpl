dnf install -y oracle-epel-release-el8
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf config-manager --set-enabled ol8_codeready_builder
