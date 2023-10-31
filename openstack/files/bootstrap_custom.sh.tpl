cat <<EOF > /etc/hosts
$(ip route get 1.1.1.1 | grep -oP 'src \K\S+') mgmt
127.0.0.1 localhost
EOF

cat <<EOF > /tmp/startnode.yaml
csp: openstack
network_id: ${network_id}
network_name: ${network_name}
security_group: ${security_group}
cluster_id: ${cluster_id}
ansible_repo: ${ansible_repo}
ansible_branch: ${ansible_branch}
ceph_network: ${ceph_network}
EOF

mkdir -p /etc/ansible/facts.d/
echo "{\"secret\":\"${ceph_secret}\"}" > /etc/ansible/facts.d/citc_ceph.fact
chown root:root /etc/ansible/facts.d/citc.fact
chmod u=rw,g=,o= /etc/ansible/facts.d/citc.fact
