#!/bin/bash

exit 0


diskutil list [DeviceNode]

diskutil u[n]mount [force] MountPoint|DiskIdentifier|DeviceNode

diskutil mount [readOnly] [-mountPoint Path] DiskIdentifier|DeviceNode

diskutil apfs unlockVolume disk5s1 -passphrase hello
