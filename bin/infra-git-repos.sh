#!/bin/bash

set -o errexit

CMD_PULL=n
OPT_PATH=n
OPT_SHORT_ROOT_DIR=n
ROOT_DIR="$PWD"
DIRS_FILE="$(mktemp)"
MAX_LENGTH_NAME=0

for p in "$@"; do
  case "$p" in
  "-pull") CMD_PULL=y ;;
  "-path") OPT_PATH=y ;;
  "-root-short") OPT_SHORT_ROOT_DIR=y ;;
  "-help" | "-h") echo "flags [-pull|-path|-root-short]"; exit ;;
  *)
    if [ -d "$p" ]; then
      ROOT_DIR="$p"
      continue
    fi

    echo "[ERRO] unknown flag [${p}]" 1>&2
    exit
    ;;
  esac
done

ROOT_DIR="$(cd "$ROOT_DIR" || return 1; pwd)"

# $1 - файл, в который записывается результат
# $2 - директория
# $3 - уровень вложенности
# $4 - префикс сортировка
# $5 - индекс
fn_iterator() {
  local store_f="$1" dir="$2" level="$3" prefix="$4" index="$5" first_index="$5" path name child_counts=0

  if [ -d "${dir}/.git" ]; then
    echo "${prefix}a${index} ${level} typ_git 0 ${dir}" >>"$store_f"
    name="$(basename "$dir")"
    len="$((${#name} + (level * 3)))"
    [ "$len" -gt "$MAX_LENGTH_NAME" ] && MAX_LENGTH_NAME="$len"
    return 0
  fi

  prefix="${prefix}b${index}"
  ((level++))

  for path in $(find "${dir}/" -not -path "${dir}/" -maxdepth 1 -type d | sort); do
    ((index++))
    fn_iterator "$store_f" "$path" "$level" "${prefix}" "$index" && ((child_counts++)) || :
  done

  [ "$child_counts" -ne 0 ] || return 11

  echo "${prefix}${first_index} $((level - 1)) typ_root ${child_counts} ${dir}" >>"$store_f"
}

fn_iterator "$DIRS_FILE" "$ROOT_DIR" "0" "" "1000"


MAX_LENGTH_NAME="$((MAX_LENGTH_NAME + 3))"
[ "$MAX_LENGTH_NAME" -gt "60" ] && MAX_LENGTH_NAME="60"

pipe() {
  local level type elem_count path indexes child_counts last
  local color_state_clear not_clear branch name_len error

  while read -r line; do
    level=$(echo "$line" | awk '{print $2}')
    type=$(echo "$line" | awk '{print $3}')
    elem_count=$(echo "$line" | awk '{print $4}')
    path=$(echo "$line" | awk '{print $5}')

    if [ "$type" = "typ_root" ]; then
      child_counts["$((level + 1))"]="$elem_count"
      indexes["$((level + 1))"]=0
    fi
    ((indexes["$level"]++))
    [ "${indexes[$level]}" = "${child_counts[$level]}" ] && last=y || last=

    for ((i = 1; i <= "$level"; i++)); do
      if [ "$i" -eq "$level" ]; then
        [ "$last" = y ] && printf '`-- ' || printf '|-- '
      else
        [ "$i" -ne 1 ] && [ "$i" -ne "$level" ] && printf "    " || printf "|   "
      fi
    done

    if [ "$type" = "typ_root" ]; then
      printf "\033[36m%s\033[0m\n" "$([ "$OPT_SHORT_ROOT_DIR" = y ] && basename "$path" || echo "$path")"
      continue
    fi

    color_state_clear="\033[32m"
    not_clear=" "
    error=

    git -C "$path" diff --exit-code 1>/dev/null &&
      git -C "$path" diff --cached --exit-code 1>/dev/null ||
      not_clear=x
    if ! branch=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>&1); then
      error="$branch"
      branch=""
    fi

    [ "$not_clear" = x ] && color_state_clear="\033[33m"

    name_len="$((MAX_LENGTH_NAME - (level * 4)))"
    printf "%-${name_len}s ${color_state_clear}[${not_clear}]\033[0m ${branch}" \
      "$(basename "$path")"

    [ "$OPT_PATH" = y ] && printf " \033[43m\033[30m %s \033[0m" "$path"

    if [ -n "$error" ]; then
      printf " \033[31m%s\033[0m" "$(echo "$error" | tr -s '[:space:]' ' ')"
      echo
      continue
    fi

    if [ "$CMD_PULL" = y ] && [ "$not_clear" != x ]; then
      if ! error="$(GIT_SSH_COMMAND="ssh -o ConnectTimeout=1" git -C "$path" pull origin --no-rebase --no-commit -q 2>&1)"; then
        printf " \033[31m%s\033[0m" "$(echo "$error" | tr -s '[:space:]' ' ')"
        echo
        continue
      fi

      printf " \033[32mpull ok\033[0m"
    fi

    echo
  done
}

sort "$DIRS_FILE" | pipe
