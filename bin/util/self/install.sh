#!/bin/sh

#
#
#

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

[ -z "$HOME" ] && echo "[ERRO][$0] not set HOME variable" && exit 1
ADDITIONAL_PROFILE="$(cd "${ROOT}/../../../configs" && pwd)/terminal-profile.sh"
[ $? -ne 0 ] && echo "[ERRO][$0] getting terminal-profile.sh"

PROFILE=
if [ -f "${HOME}/.zshrc" ]; then
  PROFILE="${HOME}/.zshrc"
elif [ -f "${HOME}/.bashrc" ]; then
  PROFILE="${HOME}/.bashrc"
else
  echo "[ERRO][$0] file of profile not exist [~/.zshrc | ./bashrc]"
  exit 1
fi

ERR_OUT=$(grep -iq "$ADDITIONAL_PROFILE" "$PROFILE" 2>&1)
case $? in
0)
  echo "[INFO][$0] Path to infrastructure profile [${ADDITIONAL_PROFILE}] has already been added"
  ;;
1)
  {
    echo ""
    echo "## adding to PATH in infrastructure utilities"
    echo "source ${ADDITIONAL_PROFILE}"
    echo ""
  } >>"$PROFILE"

  echo "[INFO][$0] Path to infrastructure profile file [${ADDITIONAL_PROFILE}] been added"
  ;;
*) echo "[ERRO][$0] check file profile (${ERR_OUT})" ;;
esac
