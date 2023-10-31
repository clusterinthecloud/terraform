#!/bin/bash

date

${custom_block}

cat > /root/citc_authorized_keys <<EOF
${citc_keys}
EOF

dnf install -y git python36 python3.11 glibc-langpack-en.x86_64
localectl set-locale en_GB.utf8
localectl set-keymap gb

# Install Ansible
mkdir -p /opt/venvs/
python3.11 -m venv /opt/venvs/ansible
/opt/venvs/ansible/bin/pip install "ansible ~= 8.0"

cat > /root/hosts <<EOF
[management]
$(hostname -f) ansible_connection=local ansible_python_interpreter=/usr/bin/python3.6
EOF

mkdir -p /etc/ansible/facts.d/
echo "{\"csp\":\"${cloud-platform}\", \"fileserver_ip\":\"${fileserver-ip}\", \"mgmt_hostname\":\"${mgmt_hostname}\", \"cluster_id\":\"${cluster_id}\"}" > /etc/ansible/facts.d/citc.fact


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
source /opt/venvs/ansible/bin/activate
ansible-playbook --inventory=/root/hosts "\$@" management.yml 2>&1 | tee -a /root/ansible-pull.log
EOF
chmod +x /root/run_ansible

/root/run_ansible

date
