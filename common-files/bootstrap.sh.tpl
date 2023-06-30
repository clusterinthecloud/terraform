#!/bin/bash

date

${custom_block}

cat > /root/citc_authorized_keys <<EOF
${citc_keys}
EOF

# Don't install ansible from a repo - instead
# install into the system python
# (eventually move this into a python venv that
#  we control)
yum install -y git
pip3.6 install ansible
cat > /root/hosts <<EOF
[management]
$(hostname -f) ansible_connection=local
EOF

mkdir -p /etc/ansible/facts.d/
echo "{\"csp\":\"${cloud-platform}\", \"fileserver_ip\":\"${fileserver-ip}\", \"mgmt_hostname\":\"${mgmt_hostname}\"}" > /etc/ansible/facts.d/citc.fact

PYTHON=$(command -v python || command -v python3)
git clone --branch "${ansible_branch}" "${ansible_repo}" /root/citc-ansible

cat > /root/update_ansible_repo <<EOF
#! /bin/bash
cd /root/citc-ansible
git pull --autostash --rebase
EOF
chmod +x /root/update_ansible_repo

cat > /root/run_ansible <<EOF
#! /bin/bash
cd /root/citc-ansible
/usr/local/bin/ansible-playbook --inventory=/root/hosts "\$@" management.yml 2>&1 | tee -a /root/ansible-pull.log
EOF
chmod +x /root/run_ansible

/root/run_ansible

date
