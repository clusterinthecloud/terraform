#!/bin/bash

date

${custom_block}

yum install -y ansible git
cat > /root/hosts <<EOF
[management]
$(hostname -f)
EOF

mkdir /etc/ansible/facts.d/
echo "{\"csp\":\"${cloud-platform}\", \"fileserver_ip\":\"${fileserver-ip}\", \"mgmt_hostname\":\"${mgmt_hostname}\"}" > /etc/ansible/facts.d/citc.fact

PYTHON=$(command -v python3 || command -v python)
time $PYTHON -u /usr/bin/ansible-pull --url=https://github.com/clusterinthecloud/ansible.git --checkout=${ansible_branch} --inventory=/root/hosts management.yml >> /root/ansible-pull.log

date
