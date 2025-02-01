

export $(cat ./file.env | sed 's/#.*//g' | xargs)


_BIN_=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")


# получить и удалить последний аргумент функции
LAST_ELEM_CMD="${@: -1}"
set -- "${@:1:$(($#-1))}"




<<EOF
apt-get update
apt-get install -y \
    package-bar \
    package-baz \
    package-foo
EOF


# Manages log file rotation
# $1 - path to log file
# $2 - max size in bytes
# $3 - optional - number of files, default = 1
# example:
# func_logs_maintain ~/example.log 1024000 3
# result:
# example.log example.log
# example.log example.log.1
# example.log example.log.2
func_logs_maintain() {
  [ -f $1 ] || return 0
  size="$(stat --printf="%s" "$1")"
  [ "$size" -lt $2 ] && return 0

  ind="$3"
  [ -z "$ind" ] && ind=2
  ind=$((ind-1))
  if [ "$ind" -le "0" ]; then : > $1; return 0; fi

  prev_file=
  while [ "$ind" -ge "0" ]; do
    f="$1"
    [ "$ind" -ne "0" ] && f="${f}.${ind}"

    if [ -n "$prev_file" ] && [ -f "$f" ]; then
      mv "$f" "$prev_file"
    fi

    prev_file="$f"
    ind=$((ind-1))
  done
}
