#!/bin/sh

#
# работа с QR кодами
#
# sh bin/_utils/qr_code/qr_code.sh scan bin/_tmp_dir/amazon-in.png -yes -debug  -hash 'sdfs dsdf' -issuer 'sadfsadf__sdfsf'
# sh bin/_utils/qr_code/qr_code.sh generate bin/_tmp_dir/qr-output.png -yes -debug -hash 'TY3LB3HQS7ZO4TTZD4PEVH3CWP7BSI3IQFD36LVJWFDLCTOKK37Q' -issuer 'Amazon'
#
# QR-Code:otpauth://totp/Amazon%3Asemenovem%40gmail.com?secret=TY3LB3HQS7ZO4TTZD4PEVH3CWP7BSI3IQFD36LVJWFDLCTOKK37Q&issuer=Amazon
#
# TY3LB3HQS7ZO4TTZD4PEVH3CWP7BSI3IQFD36LVJWFDLCTOKK37Q
#
# otpauth://totp/semenovem@gmail.com?secret=TY3LB3HQS7ZO4TTZD4PEVH3CWP7BSI3IQFD36LVJWFDLCTOKK37Q&issuer=Test2
# otpauth://totp/semenovem@gmail.com/Test3?secret=TY3LB3HQS7ZO4TTZD4PEVH3CWP7BSI3IQFD36LVJWFDLCTOKK37Q

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

FILE_ABSOLUTE_PATH=
FILE_PATH=
FILE_NAME=
FILE_REST_ARGS=
HASH=
ISSUER=
ACCOUNT=
RAW=
OPER=
ERR=
CANCEL=
IMAGE="envi/qr:1.0"

help() {
  __info__ "[help] use: [scan file.png] | [generate [file.png] -issuer xxxx] | [generate [file.png] -raw"
}

[ -n "$__HELP__" ] && help && exit 0

CMD=$(__core_get_virtualization_app__) || exit 1

debug() {
  __debug__ "---------------------"
  __debug__ "OPER               = ${OPER}"
  __debug__ "CMD                = ${CMD}"
  __debug__ "file_path          = ${FILE_PATH}"
  __debug__ "file_name          = ${FILE_NAME}"
  __debug__ "file_absolute_path = ${FILE_ABSOLUTE_PATH}"
  __debug__ "hash               = ${HASH}"
  __debug__ "-issuer            = ${ISSUER}"
  __debug__ "-account           = ${ACCOUNT}"
  __debug__ "-raw(arg)          = ${RAW}"
  __debug__ "raw(value)         = ${RAW_VALUE}"
  [ -n "$ERR" ] && __debug__ "ERR                = ${ERR}"
  __debug__ "---------------------"
}

# Разбор параметров
FILE_REST_ARGS=$(__core_conf_get_rest_args__)
if [ $? -eq 0 ]; then
  prev=
  line=
  while read -r line; do
    if [ -n "$prev" ]; then
      case $prev in
      "issuer") ISSUER="$line" ;;
      "account") ACCOUNT="$line" ;;
      *)
        __err__ "argument '$prev' has no key"
        ERR=1
        exit 1
        ;;
      esac

      prev=
      continue
    fi

    case $line in
    "scan" | "generate")
      [ -n "$OPER" ] && ERR=1 && __err__ "operation listed twice '$OPER' и '$line'" && exit 1
      OPER="$line"
      ;;
    "-issuer") prev="issuer" ;;
    "-user" | "-account") prev="account" ;;
    "-raw") RAW=1 ;;
    *)
      # проверка на файл
      if [ -f "$line" ] || [ -d "$(dirname "$line")" ]; then
        [ -n "$FILE_PATH" ] &&
          __err__ "2 files passed in arguments '$FILE_PATH' и '$line'" &&
          exit 1

        FILE_PATH="$line"
        continue
      fi

      __err__ "unknown argument '$line'"
      ERR=1
      ;;
    esac
  done <"$FILE_REST_ARGS"

  unset prev line
fi

[ -z "$OPER" ] && ERR=1 && __err__ "no operation specified"

if [ -n "$FILE_PATH" ]; then
  FILE_NAME=$(basename "$FILE_PATH")
  [ $? -ne 0 ] && ERR=1 && __err__ "failed to get filename"

  FILE_ABSOLUTE_PATH=$(__absolute_path__ "$FILE_PATH")
  [ $? -ne 0 ] && ERR=1 && __err__ "unable to get absolute path to file [${FILE_PATH}]"
fi

if [ -n "$ERR" ]; then
  [ -n "$__DEBUG__" ] && debug
  help
  exit 1
fi

# подготовка данных
case $OPER in
"scan")
  if [ -z "$FILE_ABSOLUTE_PATH" ]; then
    __err__ "file with qr code is not specified"
    ERR=1
  else
    [ ! -f "$FILE_ABSOLUTE_PATH" ] && ERR=1 && __err__ "файл не существует '$FILE_ABSOLUTE_PATH'"
  fi
  ;;

"generate")
  [ -n "$RAW" ] && [ -n "$ISSUER" ] && ERR=1 && __err__ "flags -raw and -issuer are not compatible"
  [ -n "$RAW" ] && [ -n "$ACCOUNT" ] && ERR=1 && __err__ "flags -raw and -account are not compatible"

  if [ -n "$RAW" ] && [ -z "$ERR" ]; then
    while true; do
      read -rp "copy paste raw string for generate QR code: " RAW_VALUE
      [ -n "$RAW_VALUE" ] && break
    done
  fi

  if [ -z "$RAW" ] && [ -z "$ERR" ]; then
    if [ -z "$ISSUER" ]; then
      :
      while true; do
        read -rp "укажите issuer или [n] что бы пропустить: " ans
        case $ans in
        "") ;;
        "n" | "N") break ;;
        *)
          choice=
          while true; do
            read -rp "установить issuer=$ans ? [y/N] " ans2
            case $ans2 in
            "y" | "Y") choice=1 && ISSUER="$ans" && break ;;
            "" | "n" | "N") break ;;
            *) ;;
            esac
          done

          [ -n "$choice" ] && break
          ;;
        esac
        [ -n "$HASH" ] && break
      done

      unset ans ans2 choice
    fi

    while true; do
      read -rp "copy paste secret: " HASH
      [ -n "$HASH" ] && break
    done
  fi

  if [ -n "$FILE_ABSOLUTE_PATH" ] && [ -f "$FILE_ABSOLUTE_PATH" ] && [ -z "$ERR" ]; then
    __confirm__ "file [${FILE_PATH}] already exists, overwrite ?" || CANCEL=1
  fi

  if [ -z "$FILE_ABSOLUTE_PATH" ] && [ -z "$ERR" ]; then
    FILE_ABSOLUTE_PATH=$(mktemp)
    [ $? -ne 0 ] && ERR=1 && __err__ "failed to create temporary file for qr code"

    FILE_NAME=$(basename "$FILE_ABSOLUTE_PATH")
    [ $? -ne 0 ] && ERR=1 && __err__ "failed to get filename"

    [ -z "$ERR" ] && __info__ "path to file with qr code: ${FILE_ABSOLUTE_PATH}"
  fi
  ;;
esac

[ -n "$__DEBUG__" ] && debug
[ -n "$ERR" ] && help && exit 1
[ -n "$CANCEL" ] && exit 0

__core_has_docker_image__ "$IMAGE"
case $? in
0) ;;
1)
  [ -n "$__DRY__" ] && __info__ "image assembly" && exit 0
  $CMD build -f "${ROOT}/qr_code.dockerfile" -t "$IMAGE" "$ROOT" || exit 1
  ;;
*) exit 1 ;;
esac

#
#
#
case $OPER in
"scan")
  [ -n "$__DRY__" ] && exit 0

  $CMD run -it --rm \
    --user "$(id -u):$(id -g)" \
    -w /app \
    -v "${FILE_ABSOLUTE_PATH}:/app/${FILE_NAME}" \
    "$IMAGE" sh -c "zbarimg /app/${FILE_NAME} --nodbus -q"
  ;;

"generate")
  if [ ! -f "$FILE_ABSOLUTE_PATH" ]; then
    touch "$FILE_ABSOLUTE_PATH"
    [ $? -ne 0 ] && __err__ "failed to create file [${FILE_ABSOLUTE_PATH}]" && exit 1
  fi

  if [ -n "$RAW" ]; then
    param="$RAW_VALUE"
  else
    param="otpauth://totp"
    [ -n "$ACCOUNT" ] && param="${param}/${ACCOUNT}" || param="${param}/${ISSUER}"
    param="${param}?secret=${HASH}"
    [ -n "$ACCOUNT" ] && [ -n "$ISSUER" ] && param="${param}&issuer=${ISSUER}"

    __debug__ "query: $param"
  fi

  [ -n "$__DRY__" ] && exit 0

  $CMD run -it --rm \
    --user "$(id -u):$(id -g)" \
    -w /app \
    -v "${FILE_ABSOLUTE_PATH}:/app/${FILE_NAME}" \
    "$IMAGE" sh -c "qrencode -s 6 -l H -o '${FILE_NAME}' '$param'" || exit 1

  which open >/dev/null || exit 1

  open -a Preview "$FILE_ABSOLUTE_PATH"
  ;;
esac
