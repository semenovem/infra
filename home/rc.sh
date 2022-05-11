#!/bin/bash

function __err__ {
  echo -e "[ERROR] [$(date)] $@" >>"${HOME}/_evg-logfile.logs"
}

function __resource__ {
  local file dir=$1

  [ -z "$dir" ] && __err__ "no argument passed. must be name of directory"
  [ ! -d "$dir" ] && __err__ "directory '${__DIR__}' does not exist"

  for file in "${dir:?}"/*.sh; do
    # shellcheck disable=SC1090
    source "$file"
  done
}
