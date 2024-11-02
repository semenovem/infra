

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
