#!/bin/bash

__SELF_SYSCTL_STATE_DIR__="${HOME}/_self_sysctl"

[ ! -d ] && mkdir -p "$__SELF_SYSCTL_STATE_DIR__"

function __info__ {
  echo "[INFO] [$(date)] $*"
}

function __debug__ {
  echo "[DEBU] [$(date)] $*"
}
