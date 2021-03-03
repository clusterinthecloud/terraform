#!/bin/bash

date

${custom_block}

cat > /root/citc_authorized_keys <<EOF
${citc_keys}
EOF

%{ if !running_in_test_suite }
# Notify the CitC developers that a cluster has been installed.
# Only the cloud platform used (Google, AWS etc) and the randomly-generated cluster id are sent.
# See https://... for more information
curl --silent "https://europe-west2-citc-logging.cloudfunctions.net/new-cluster-v1?csp=${cloud-platform}&cluster_id=${cluster_id}"
%{ endif }

yum install -y ansible git
cat > /root/hosts <<EOF
[management]
$(hostname -f)
EOF

mkdir /etc/ansible/facts.d/
echo "{\"csp\":\"${cloud-platform}\", \"fileserver_ip\":\"${fileserver-ip}\", \"mgmt_hostname\":\"${mgmt_hostname}\"}" > /etc/ansible/facts.d/citc.fact

PYTHON=$(command -v python || command -v python3)
time $PYTHON -u /usr/bin/ansible-pull --url=${ansible_repo} --checkout=${ansible_branch} --inventory=/root/hosts management.yml >> /root/ansible-pull.log

date
