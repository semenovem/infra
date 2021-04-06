
exit

# install https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"



### mount remote directory

# to install
brew cask install osxfuse
brew install sshfs

# execute
sshfs evg@192.168.1.8:/ ~/_mount

# cancel
umount evg@192.168.1.8:/
