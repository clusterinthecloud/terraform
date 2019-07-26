#!/bin/bash

date

echo milliams

yum install -y ansible git
cat > /root/hosts <<EOF
[management]
$(hostname -f)
EOF

mkdir /etc/ansible/facts.d/
echo "{\"csp\":\"${cloud-platform}\", \"fileserver_ip\":\"${fileserver-ip}\"}" > /etc/ansible/facts.d/csp.fact

time python -u /usr/bin/ansible-pull --url=https://github.com/ACRC/slurm-ansible-playbook.git --checkout=${ansible_branch} --inventory=/root/hosts management.yml >> /root/ansible-pull.log

date
