#!/bin/bash

date

yum install -y ansible git
cat > /root/hosts <<EOF
[nfsserver]
$(hostname -f)

[all:vars]
cluster_id=${cluster_id}
EOF

time python -u /usr/bin/ansible-pull --url=https://github.com/ACRC/slurm-ansible-playbook.git --checkout=${ansible_branch} --inventory=/root/hosts nfsserver.yml >> /root/ansible-pull.log

date
