#!/bin/bash

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

sh "${ROOT}/../../bin/utils/backup/git-dirs.sh"
