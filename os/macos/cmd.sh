#!/bin/bash

exit

# shows cpu temperature
sudo powermetrics | grep -i "CPU die temperature"


# creates a file of the specified size
# maximum file size for FAT32 - 4,294,967,295b ( or 4G - 1 )
mkfile 1g test.abc

dd if=/dev/zero of=output.dat bs=10m

# or
truncate -s 10240 file2


# -----------
brew install smartmontools

diskutil list

smartctl -x disk0


# ----------- install
brew install jq  # https://stedolan.github.io/

# create a ram-disk ( 3 gb * 1024 * 2048 = 6291456 )
diskutil erasevolume HFS+ 'ram_disk' `hdiutil attach -nobrowse -nomount ram://6291456`
