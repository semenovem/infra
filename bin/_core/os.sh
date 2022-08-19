#!/bin/sh

#
# Определение OS
#

__CORE_OS_KIND__=        # тип OS
__CORE_OS_LINUX_DISTR__= # дистрибутив linux

# константы типов OS
__CORE_OS_KIND_UNIX_CONST__="UNIX"
__CORE_OS_KIND_LINUX_CONST__="LINUX"
__CORE_OS_KIND_MACOS_CONST__="MACOS"

# константы linux дистрибутивов
__CORE_OS_LINUX_DISTR_DEBIAN_CONST__="DEBIAN"
__CORE_OS_LINUX_DISTR_RASPBIAN_CONST__="RASPBIAN"
__CORE_OS_LINUX_DISTR_FEDORA_CONST__="FEDORA"

__CORE_OS_IS_MACOS__=
__CORE_OS_IS_FEDORA__=
__CORE_OS_IS_DEBIAN__=
__CORE_OS_IS_RASPBIAN__=

CORE_OS_RELEASE="/etc/os-release"

if [ -f "$CORE_OS_RELEASE" ]; then
  __CORE_OS_KIND__="$__CORE_OS_KIND_LINUX_CONST__"
  __OS_LINUX_KIND__="$__CORE_OS_KIND_LINUX_CONST__"

  grep -iE "^ID_LIKE=debian" "$CORE_OS_RELEASE" -q &&
    __CORE_OS_IS_DEBIAN__=1 &&
    __CORE_OS_LINUX_DISTR__="$__CORE_OS_LINUX_DISTR_DEBIAN_CONST__"

  grep -iE "^ID=raspbian" "$CORE_OS_RELEASE" -q &&
    __CORE_OS_IS_RASPBIAN__=1 &&
    __CORE_OS_LINUX_DISTR__="$__CORE_OS_LINUX_DISTR_RASPBIAN_CONST__"

  grep -iE "^ID_LIKE=" "$CORE_OS_RELEASE" | grep -i -q "fedora" &&
    __CORE_OS_IS_FEDORA__=1 &&
    __CORE_OS_LINUX_DISTR__="$__CORE_OS_LINUX_DISTR_FEDORA_CONST__"

else

  # TODO проверить, что является OS macos
  __CORE_OS_KIND__="$__CORE_OS_KIND_MACOS_CONST__"
  __CORE_OS_IS_MACOS__=1
fi
