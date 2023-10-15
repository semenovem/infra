#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1
. "${ROOT}/../../_lib/role.sh" || exit 1

__core_role_get__ || __warn__ "Ошибка получения роли"
