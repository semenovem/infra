#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

# shellcheck disable=SC2068
sh "${ROOT}/util/openvpn/run.sh" $@
