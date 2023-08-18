cat <<EOF > /etc/hosts
$(ip route get 1.1.1.1 | grep -oP 'src \K\S+') mgmt fileserver
127.0.0.1 localhost
EOF

cat <<EOF > /tmp/startnode.yaml
csp: openstack
network_id: ... # TODO
cluster_id: ${cluster_id} # TODO
ansible_repo: ${ansible_repo}
ansible_branch: ${ansible_branch}
EOF
