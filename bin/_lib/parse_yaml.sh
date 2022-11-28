#!/bin/sh

# парсинг yaml
# $1 - файл yaml
# $2 - префикс запрошенного значения
# return 0 - все ок
# return 10 - ничего не найдено
# TODO добавить кеширование результата в tmp файл в envi_state, сроком действия 1 час

PREFIX="$2"

if [ -n "$PREFIX" ]; then
  echo "$PREFIX" | grep -iEq "^_|_$" &&
    echo "Префикс не должен начинаться и заканчиватся с [_]" >&2 && exit 1
fi

parse_yaml_pipe() {
  while read -r line; do
    [ -z "$PREFIX" ] && echo "$line" && continue      # нет префикса для фильтра
    echo "$line" | grep -iEq "^${PREFIX}" || continue # не соответствует префиксу
    echo "$line" | sed "s/${PREFIX}//"                # убрать префикс
    IS_FOUND=1
  done
}

s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @ | tr @ '\034')
sed -ne "s|^\($s\):|\1|" \
  -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
  -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
  awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         vvv=(3)
         printf("%s%s=%s\n", vn, $2, $vvv);
      }
   }' | grep -iEo "^[^#]+" | parse_yaml_pipe || exit $?
