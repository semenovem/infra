#!/bin/bash

exit

# shows cpu temperature
sudo powermetrics | grep -i "CPU die temperature"


# creates a file of the specified size
# maximum file size for FAT32 - 4,294,967,295b ( or 4G - 1 )
mkfile 1g test.abc

dd if=/dev/zero of=output.dat bs=10m
