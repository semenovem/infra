#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_core/conf.sh"
. "${ROOT}/../_core/logger.sh"
. "${ROOT}/../_core/role.sh"

__core_role_get__ || __warn__ "Ошибка получения роли"
