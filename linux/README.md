


### mount remote directory
```
# to install
brew cask install osxfuse
brew install sshfs

# execute
sshfs evg@192.168.1.8:/ ~/mount

# cancel
umount evg@192.168.1.8:/

```