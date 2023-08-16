cat <<EOF > /etc/hosts
$(ip route get 1.1.1.1 | grep -oP 'src \K\S+') mgmt
127.0.0.1 localhost
EOF
