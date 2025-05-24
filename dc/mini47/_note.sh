
apt-get -y install autossh

# /etc/ssh/sshd_config
PasswordAuthentication no
PermitRootLogin no
AllowTcpForwarding yes



docker run -it --rm --name windows -p 8006:8006 \
  --device=/dev/kvm --device=/dev/net/tun \
  --cap-add NET_ADMIN \
  -v "/mnt/dat-vol/windows:/storage:rw"\
  -v "/mnt/dat-vol/win11arm64.iso:/boot.iso:ro" \
  --stop-timeout 120 \
  dockurr/windows



------------
# fstab
# 500Gb nvm
PARTUUID="f355333a-01" /mnt/dat-vol  ext4  defaults,nofail  0 0

# 1T hdd
UUID="c70d4195-fdfd-4119-a55b-1833f6ae5920" /mnt/media_vol  ext4  defaults,nofail  0 0

tmpfs  /mnt/ramfs  tmpfs  rw,size=100M  0   0

/dev/sdc 

# /mnt/dat-vol/xeoma-archive  /mnt/xeoma-archive  bind    defaults,nofail,bind 0 0


# Xeoma
/usr/local/Xeoma/XeomaArchive/
Settings path: /usr/local/Xeoma
Executable file's path: /home/evg/bin/Xeoma/xeoma
ttL2BtWSzu

# /mnt/dat-vol/xeoma-archive
