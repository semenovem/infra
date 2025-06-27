#!/bin/bash

# list of platforms
# PLATFORM_RASPBIAN
# PLATFORM_LINUX_UBUNTU
# PLATFORM_LINUX_DEBIAN

which "/usr/bin/raspi-config" >/dev/null 2>&1 && echo "PLATFORM_RASPBIAN" && exit 0

case "$(uname)" in
  'Linux') echo 'PLATFORM_LINUX' ;;
  'Darwin')
    uname -a | grep -iq ARM64 && \
    echo "PLATFORM_MACOS_ARM64" || echo 'PLATFORM_MACOS_INTEL'

    exit 0
  ;;
*) echo "PLATFORM_UNKNOWN";;
esac
