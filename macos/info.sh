
exit

# install https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"



### mount remote directory via ssh
# https://osxfuse.github.io/
# https://github.com/osxfuse/sshfs


# execute
sshfs evg@192.168.1.8:/ ~/_mount

# cancel
umount ~/_mount
