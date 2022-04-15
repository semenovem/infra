#!/bin/bash

echo "############################################################"
echo "# openvpn                                                  #"
echo "############################################################"

__BIN__=$(dirname "$([[ $0 == /* ]] && echo "$0" || echo "$PWD/${0#./}")")
#__TARGET__="${HOME}/easy-rsa"
__TARGET__="${__BIN__}/easy-rsa"

__PKI__="${__TARGET__}/pki"
__CA_CERT__="${__PKI__}/ca.crt"
__CONFIGS__="${__TARGET__}/configs"
__SECRET_TA__="${__TARGET__}/ta.key"
__SYSCTL_CONF__="/etc/sysctl.conf"
__SERVER__CONF__="/etc/openvpn/server"
__SERVER__CONF_FILE__="${__SERVER__CONF__}/server.conf"
__SERVER_CURVE__="prime256v1"

__SERVER1_CN__="rr3-server1-evg"
__SERVER2_CN__="rr3-server2-evg"
__SERVER3_CN__="rr3-server3-evg"

__CLIENT_BASE_CONFIG__="${__BIN__}/client.conf"
# secp256k1
__CLIENT_CURVE__="prime256v1"
__CLIENT1_CN__="rr3-client1-evg"
__CLIENT2_CN__="rr3-client2-evg"
__CLIENT3_CN__="rr3-client3-evg"
__CLIENT4_CN__="rr3-client4-evg"
__CLIENT5_CN__="rr3-client5-evg"

__DEBUG__=true
__DEV_MODE__=
__CONFIRM_YES__=
__IS_SYSTEM_READINESS__=
__IS_CA_INSTALLED__=
__IS_OPENVPN_INSTALLED__=

export PATH="${__TARGET__}:${PATH}"

__RED__='\033[0;31m'
__GREEN__='\033[0;32m'
__YELLOW__='\033[1;33m'
__BLUE__='\033[0;34m'
__LIGHT_BLUE__='\033[1;34m'
__PURPLE__='\033[0;35m'
__CYAN__='\033[0;36m'
__LIGHT_GRAY__='\033[0;37m'
__DARK_GRAY__='\033[1;30m'
__LIGHT_RED__='\033[1;31m'
__LIGHT_GREEN__='\033[1;32m'
__NC__='\033[0m' # No Color
__BACKGROUND_BLACK__='\033[40m'
__BACKGROUND_RED__='\033[41m'
__BACKGROUND_GREEN__='\033[42m'
__BACKGROUND_YELLOW__='\033[43m'
__BACKGROUND_DARK_BLUE__='\033[44m'
__BACKGROUND_BLUE__='\033[46m'
__BACKGROUND_PURPLE__='\033[45m'
__BACKGROUND_GRAY__='\033[47m'

function Top_() {
  local txt=$* suff
  suff=$(printf '%*s' "$((60 - ${#txt}))" "|")
  echo -e "${__BACKGROUND_RED__}${__YELLOW__}${txt}${suff}${__NC__}"
}
function Red_() {
  echo -e "${__RED__}$*${__NC__}"
}
function LRed_() {
  echo -e "${__LIGHT_RED__}$*${__NC__}"
}
function Gree() {
  echo -e "${__GREEN__}$*${__NC__}"
}
function LGre() {
  echo -e "${__LIGHT_GREEN__}$*${__NC__}"
}
function Yell() {
  echo -e "${__YELLOW__}$*${__NC__}"
}
function Blue() {
  echo -e "${__BLUE__}$*${__NC__}"
}
function LBlu() {
  echo -e "${__LIGHT_BLUE__}$*${__NC__}"
}
function LGra() {
  echo -e "${__LIGHT_GRAY__}$*${__NC__}"
}
function DGra() {
  echo -e "${__DARK_GRAY__}$*${__NC__}"
}
function Cyan() {
  echo -e "${__CYAN__}$*${__NC__}"
}
function Purp() {
  echo -e "${__PURPLE__}$*${__NC__}"
}
function BackgroundRed() {
  echo -e "${__BACKGROUND_RED__}$*${__NC__}"
}
function BackgroundGreen() {
  echo -e "${__BACKGROUND_GREEN__}$*${__NC__}"
}
function BackgroundYellow() {
  echo -e "${__BACKGROUND_YELLOW__}$*${__NC__}"
}
function BackgroundDarkBlue() {
  echo -e "${__BACKGROUND_RED__}$*${__NC__}"
}
function BackgroundBlue() {
  echo -e "${__BACKGROUND_BLUE__}$*${__NC__}"
}
function BackgroundPurple() {
  echo -e "${__BACKGROUND_PURPLE__}$*${__NC__}"
}
function BackgroundGray() {
  echo -e "${__BACKGROUND_GRAY__}$*${__NC__}"
}
function Info() {
  LBlu "INFO: $*"
}
function Warn() {
  Yell "WARN: $*"
}
function Err() {
  Red_ "ERRO: $*"
}
function Confirm() {
  local ans msg="Confirm action ?"
  [ "$__CONFIRM_YES__" ] && return 0
  [ "$1" ] && msg="$1"
  if [ "$__DEV_MODE__" ]; then
    confirmY "$msg"
    return $?
  fi

  while true; do
    read -rp "$msg [y/N]: " ans
    case "$ans" in
      "y" | "Y" ) return 0 ;;
      "n" | "N" | "") Yell "Cancel action" && return 1 ;;
    esac
  done
}
function ConfirmY() {
  local ans msg="Confirm action ?"
  [ "$__CONFIRM_YES__" ] && return 0
  [ "$1" ] && msg="$1"
  while true; do
    read -rp "$msg [Y/n]: " ans
    case "$ans" in
      "y" | "Y" | "" ) return 0 ;;
      "n" | "N" ) Yell "Cancel action" && return 1 ;;
    esac
  done
  return 1
}
function AnyKey() {
  local lab msg
  msg=$(Purp "Для продолжения нажмите любую клавишу")
  [ "$1" ] && msg="$1"
  read -rn 1 -p "$msg: " lab
  echo
  return 0
}

# return 0 - yes
# return 1 - no
# return 2 - Quit
function SelectYesNoQ() {
  local ans msg="Продолжить ?"
  [ "$1" ] && msg="$1"
  while true; do
    read -r -p "$msg [y/n/Q]: " ans
    case "$ans" in
      "y" | "Y" ) return 0 ;;
      "n" | "N" ) return 1 ;;
      "q" | "Q" | "") return 2 ;;
    esac
  done
}

function ShowEnv() {
  local var=$1 prefix
  prefix=$(printf '%*s' "$((35 - ${#var}))" "")
  echo -e "${__BACKGROUND_DARK_BLUE__}${__YELLOW__}${var}${prefix}${__NC__} = ${!var}"
#  Cyan "${var}${prefix} = ${!var}"
}

function ShowCurrentState() {
    ShowEnv __IS_SYSTEM_READINESS__
    ShowEnv __IS_CA_INSTALLED__
    ShowEnv __IS_OPENVPN_INSTALLED__
}

function CalcCurrentState() {
  __IS_SYSTEM_READINESS__=
  __IS_OPENVPN_INSTALLED__=
  __IS_CA_INSTALLED__=true

  dnf repolist | grep -q "epel" && __IS_SYSTEM_READINESS__=true
  which openvpn &> /dev/null && __IS_OPENVPN_INSTALLED__=true
  [ ! -f "$__CA_CERT__" ] && __IS_CA_INSTALLED__=
  [ ! -f "$__SECRET_TA__" ] && __IS_CA_INSTALLED__=
}

#####################################################################
# Handling menu actions
#####################################################################

function DeletePKI() {
  rm -rf "$__PKI__" || return 1
}

function ServerIssueCert() {
    local name=$1 dir
    [ -z "$name" ] && echo "ERR: no argument passed" && return 1

    easyrsa --batch --pki-dir="$__PKI__" \
      --req-cn="$name" \
      --days="1095" \
      --use-algo="ec" \
      --curve="$__SERVER_CURVE__" \
      gen-req "$name" nopass || return 1
#      --subject-alt-name="DNS:primary.example.net,DNS:alternate.example.net,IP:203.0.113.29" \

    easyrsa --batch --pki-dir="$__PKI__" \
      sign-req server "$name" || return 1
#      --copy-ext

    dir="${__CONFIGS__}/${name}"
    mkdir -p "$dir"

    cp "${__PKI__}/issued/${name}.crt" "${dir}/server.crt"
    cp "${__PKI__}/private/${name}.key" "${dir}/server.key"
    cp "$__CA_CERT__" "$dir"
    cp "$__SECRET_TA__" "$dir"
}

function ClientIssueCert() {
    local name=$1 dir
    [ -z "$name" ] && Err "no argument passed" && return 1

    easyrsa --batch --pki-dir="$__PKI__" \
      --req-cn="$name" \
      --days="1095" \
      --use-algo="ec" \
      --curve="$__CLIENT_CURVE__" \
      gen-req "$name" nopass || return 1

    easyrsa --batch --pki-dir="$__PKI__" sign-req client "$name" || return 1

    dir="${__CONFIGS__}/${name}"
    mkdir -p "$dir"

    cp "${__PKI__}/issued/${name}.crt" "${dir}/client.crt"
    cp "${__PKI__}/private/${name}.key" "${dir}/client.key"
    cp "$__CA_CERT__" "$dir"
    cp "$__SECRET_TA__" "$dir"

cat "$__CLIENT_BASE_CONFIG__" \
<(echo -e '<ca>') \
"${dir}/ca.crt" \
<(echo -e '</ca>\n<cert>') \
"${dir}/client.crt" \
<(echo -e '</cert>\n<key>') \
"${dir}/client.key" \
<(echo -e '</key>\n<tls-crypt>') \
"${dir}/ta.key" \
<(echo -e '</tls-crypt>') \
> "${dir}/config.ovpn"

}

function FuncSystemRhel() {
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* || return 1
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' \
    /etc/yum.repos.d/CentOS-Linux-* || return 1
  dnf install centos-release-stream -y || return 1
  dnf swap centos-{linux,stream}-repos -y || return 1
  dnf distro-sync -y || return 1
  dnf install -y epel-release || return 1
  __IS_SYSTEM_READINESS__=true
}

function FuncCAInstallation() {
  if [ ! -d "/usr/share/easy-rsa" ]; then
    dnf install -y epel-release || return 1
    dnf install -y easy-rsa || return 1
  fi
  if [ -d "$__PKI__" ]; then
    Confirm "$(Warn "The PKI already exists. Delete ?")" || return 10
    DeletePKI
  fi
  if [ ! -d "$__TARGET__" ]; then
    mkdir -p "$__TARGET__" || return 1
    chmod 0700 "$__TARGET__" || return 1
    ln -s /usr/share/easy-rsa/3/* "$__TARGET__" || return 1
  fi
  mkdir -p "$__PKI__" || return 1

  easyrsa --batch --pki-dir="$__PKI__" init-pki || return 1

  easyrsa --batch --pki-dir="$__PKI__" \
    --req-cn="main-ca-evg" \
    --days="3650" \
    --use-algo="ec" \
    --curve="secp384r1" \
    build-ca nopass || return 1

  if [ ! -f "$__SECRET_TA__" ]; then
    openvpn --genkey --secret "$__SECRET_TA__" || return 1
  fi

  # creating key Diffie-Hellman
  easyrsa --pki-dir="$__PKI__" gen-dh

  __IS_CA_INSTALLED__=true
}

function FuncServerIssueCert() {
  [ -z "$__IS_CA_INSTALLED__" ] && Err "CA no installed" && return 10
  ServerIssueCert "$__SERVER1_CN__"
  ServerIssueCert "$__SERVER2_CN__"
  ServerIssueCert "$__SERVER3_CN__"
}

function FuncServerInstallation() {
  [ -z "$__IS_SYSTEM_READINESS__" ] && (dnf install -y epel-release || return 1)
  [ -z "$__IS_OPENVPN_INSTALLED__" ] && (dnf install -y openvpn || return 1)

  grep -q "net.ipv4.ip_forward" "$__SYSCTL_CONF__" \
    || sed -i '1s/^/net.ipv4.ip_forward = 1\n/' "$__SYSCTL_CONF__"

#/etc/sysctl.conf
#__SERVER__CONF__="/etc/openvpn/server"
#__SERVER__CONF_FILE__="server.conf"

  [ ! -f "$__SERVER__CONF_FILE__" ] \
    && cp "${__BIN__}/server.conf" "$__SERVER__CONF_FILE__"

  [ ! -f "${__SERVER__CONF_FILE__}/ca.crt" ] \
    && cp "${__BIN__}/server.conf" "$__SERVER__CONF_FILE__"
}

function FuncClientIssueCert() {
  [ -z "$__IS_CA_INSTALLED__" ] && Err "CA no installed" && return 10
  ClientIssueCert "$__CLIENT1_CN__"
  ClientIssueCert "$__CLIENT2_CN__"
  ClientIssueCert "$__CLIENT3_CN__"
  ClientIssueCert "$__CLIENT4_CN__"
  ClientIssueCert "$__CLIENT5_CN__"
}

# TODO work in progress
function FuncClientInstallation() {
  Info "FuncClientInstallation - work in progress"
  return 10
}

# TODO - work in progress
function FuncExportCert() {
  Info "FuncExportCert - work in progress"
  return 10
  CN_NAME=
  while [ -z "$CN_NAME" ]; do
    read -r -p "Введите метку сертификата: " lab

    [ -z "$lab" ] && continue
    [ "$notConfirm" ] && _SHARE_LABEL_="$lab" && return 0

    read -r \
      -p "$(Info "Метка сертификата: $(Gree "$lab"). Подтвердить ?  [y/n/Q]:")" ans

    case $ans in
      "y" | "Y") CN_NAME="$lab" ;;
      "n" | "N") continue ;;
      "q" | "") Yell "Отмена действия"; return 1 ;;
    esac
  done
}

function FuncDeletePKI() {
  [ ! -d "$__PKI__" ] && Warn "Nothing to delete" && return 10
  Confirm "delete PKI ?" || return 10
  DeletePKI
}

###########################################################################
# Main
###########################################################################


# parse arguments
#prev=
#for p in "$@"; do
#  if [ "$prev" ]; then
#    case $prev in
#      "-config") CONFIG_FILE="$p" ;;
#      "-cmd") _CMD_="$p" ;;
#      "-cmd-label") _CMD_LABEL_="$p" ;;
#      "-cmd-file")  _CMD_FILE_="$p" ;;
#      "-cmd-dn")    _CMD_DN_="$p" ;;
#      * ) WARN "Не известные аргументы: $prev $p" && exit 1
#    esac
#    prev=
#    continue
#  fi
#
#  case $p in
#    "-debug") __DEBUG__=true ;;
#    "-dev-mode") __DEV_MODE__=true ;;
#    "-y" | "-yes") __CONFIRM_YES__=true ;;
#    *) prev=$p
#  esac
#done
#unset prev p

CalcCurrentState
[ "$__DEBUG__" ] && ShowCurrentState

MenuItem() {
  local on item=$1 num cmd desc
  on=$(echo "$item" | awk '{print $1}')
  num=$(echo "$item" | awk '{print $2}')
  cmd=$(echo "$item" | awk '{print $3}')
  desc=$(echo "$item" | awk '{print $4,$5,$6,$7,$8,$9,$10}')
  num=$(printf '%3s' "$num")
  if [ "$on" == "on" ]; then
    cmd="[${__LIGHT_GREEN__}${cmd}${__NC__}]"
    cmd=$(printf '%-32s' "$cmd")
  else
    num="${__DARK_GRAY__}${num}"
    cmd="[${cmd}]"
    cmd=$(printf '%-15s' "$cmd")
    desc="${desc}${__NC__}"
  fi
  echo -e "${num} ${cmd} ${desc}"
}

MenuExec() {
  case $(echo "$1" | awk '{print tolower($0)}') in
    "1"  | "install") echo; FuncSystemRhel ;;
    "2"  | "ca") echo; FuncCAInstallation ;;

    "3"  | "server-cert") FuncServerIssueCert ;;
    "4"  | "server-init") FuncServerInstallation ;;

    "5"  | "client-cert") FuncClientIssueCert ;;
    "6"  | "client-init") FuncClientInstallation ;;

    "7"  | "cert-export") FuncExportCert ;;
    "10" | "delete")  FuncDeletePKI ;;
    "q"  | "exit")    exit 100 ;;
    *) return 10
  esac
}

MenuMain () {
  local ans NoCA=off YesCA=off sys=off
  [ -n "$__IS_CA_INSTALLED__" ] && NoCA=on || YesCA=on
  [ -z "$__IS_SYSTEM_READINESS__" ] && sys=on

  MenuItem "$sys   1.  sys           Install repo, dependencies"
  MenuItem "$YesCA 2.  ca            Create CA"

  MenuItem "$NoCA  3.  server-cert   Issue certificate for vpn server"
  MenuItem "on     4.  server-init   Vpn server installation"

  MenuItem "$NoCA  5.  client-cert   Issue certificate for vpn client"
  MenuItem "on     6.  client-init   Vpn client installation (for linux)"

  MenuItem "$NoCA  7.  cert-export   Certificate export"
  MenuItem "$NoCA  10. delete-pki    Delete pki"
  MenuItem "on     q.  exit          Exit"

  while true; do
    read -r -p "Выбор операции: [номер или $(LGre "command")]: " ans
    MenuExec "$ans"
    [ "$?" -eq 10 ] && continue
    break

#    while true; do
#      CalcCurrentState
#      echo
#      read -rp "[sys,ca,server] > " ans
#      MenuMainExec "$ans"
#      [ "$?" -eq 10 ] && return 0
#    done
  done
}

Main() {
  while true; do
    echo
    echo -e "${__BACKGROUND_PURPLE__}$(printf '%-80s\n' "openvpn setup")${__NC__}"
    MenuMain
    CalcCurrentState
  done
}

Main
