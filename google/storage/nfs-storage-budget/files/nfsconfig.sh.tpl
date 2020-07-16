#!/bin/bash

date

dnf install -y epel-release

yum install -y ansible git
cat > /root/hosts <<EOF
[nfsserver]
$(hostname -f)

[all:vars]
cluster_id=${cluster_id}
EOF

time python3 -u /usr/bin/ansible-pull --url=https://github.com/clusterinthecloud/ansible.git --checkout=${ansible_branch} --inventory=/root/hosts nfsserver.yml >> /root/ansible-pull.log

date
