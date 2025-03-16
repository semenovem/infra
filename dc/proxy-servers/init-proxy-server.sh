
useradd -m -N -s /bin/bash forwardman 
su forwardman

ssh-keygen -t ecdsa -b 384

touch /home/forwardman/.ssh/authorized_keys
chmod 0600 /home/forwardman/.ssh/authorized_keys
