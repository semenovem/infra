#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

sh "${ROOT}/../utils/ssh-fwrd/ssh-fwrd.sh" $@