
apt-get -y install autossh

# /etc/ssh/sshd_config
PasswordAuthentication no
PermitRootLogin no
AllowTcpForwarding yes



docker run -it --rm --name windows -p 8006:8006 \
  --device=/dev/kvm --device=/dev/net/tun \
  --cap-add NET_ADMIN \
  -v "/mnt/vol1/windows:/storage:rw"\
  -v "/mnt/vol1/win11arm64.iso:/boot.iso:ro" \
  --stop-timeout 120 \
  dockurr/windows



# Xeoma
/usr/local/Xeoma/XeomaArchive/