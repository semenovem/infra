#!/bin/bash

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

# shellcheck disable=SC2068
bash "${ROOT}/../_utils/ssh-fwrd/ssh-fwrd.sh" $@
