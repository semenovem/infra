#!/bin/bash

case "$(uname)" in
  'Linux') echo 'LINUX' ;;
  'Darwin') echo 'MACOS_ARM' ;;
*) echo "UNKNOWN";;
esac
