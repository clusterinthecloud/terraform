#!/bin/bash

date

if [[ ${cloud-platform} == aws ]]
then
  amazon-linux-extras install -y ansible2
  amazon-linux-extras install -y epel
  hostnamectl set-hostname mgmt.${dns_zone}
fi

yum install -y ansible git
cat > /root/hosts <<EOF
[management]
$(hostname -f)
EOF

mkdir /etc/ansible/facts.d/
echo "{\"csp\":\"${cloud-platform}\", \"fileserver_ip\":\"${fileserver-ip}\"}" > /etc/ansible/facts.d/citc.fact

time python -u /usr/bin/ansible-pull --url=https://github.com/ACRC/slurm-ansible-playbook.git --checkout=${ansible_branch} --inventory=/root/hosts management.yml >> /root/ansible-pull.log

date
