

export $(cat ./file.env | sed 's/#.*//g' | xargs)


_BIN_=$(dirname "$([ "$0" = '/*' ] && echo "$0" || echo "$PWD/${0#./}")")
