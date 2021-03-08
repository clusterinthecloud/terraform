#!/bin/bash

date

${custom_block}

cat > /root/citc_authorized_keys <<EOF
${citc_keys}
EOF

yum install -y ansible git
cat > /root/hosts <<EOF
[management]
$(hostname -f) ansible_connection=local
EOF

mkdir /etc/ansible/facts.d/
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
/usr/bin/ansible-playbook --inventory=/root/hosts "\$@" management.yml 2>&1 | tee -a /root/ansible-pull.log
EOF
chmod +x /root/run_ansible

/root/run_ansible

date
