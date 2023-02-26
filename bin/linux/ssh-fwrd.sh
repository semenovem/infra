#!/bin/bash

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

bash "${ROOT}/../utils/ssh-fwrd/ssh-fwrd.sh" $@
