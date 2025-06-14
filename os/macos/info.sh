
exit

# install https://brew.sh/
# todo linux-like/get_started.md
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"



### mount remote directory via ssh
# https://osxfuse.github.io/
# https://github.com/osxfuse/sshfs
# https://github.com/osxfuse/sshfs/releases

# execute
sshfs evg@192.168.11.100:/mnt ~/_mount

# if there is an error: mount_macfuse: the macFUSE kernel extension is not loaded
sudo kextunload -b io.macfuse.filesystems.macfuse

# cancel
umount ~/_mount

# -----------------------------------
# режим сна
https://www.iphones.ru/iNotes/rezhim-sna-i-gibernaciya-na-mac-chem-otlichaetsya-i-kak-nastroit-04-08-2020

pmset -g | grep hibernatemode

hibernatemode 0 – это обычный режим сна
hibernatemode 1 – это режим гибернации (для всех настольных компьютеров и ноутбуков до 2005 года выпуска)
hibernatemode 3 – режим безопасного сна
hibernatemode 25 – режим гибернации (для ноутбуков 2005 года выпуска и более новых моделей)
---

# Выбор другого режима сна
sudo pmset hibernatemode Х
Где вместо Х нужно выбрать номер подходящего режима: 0, 1, 3 или 25.


# настройка сети
networksetup

#-----------------------------------------
# Список wifi сетей
/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -s


#----------------------------------------
# https://stackoverflow.com/questions/48910876/error-eacces-permission-denied-access-usr-local-lib-node-modules
mkdir ~/.npm-global
npm config set prefix "${HOME}/.npm-global"
export PATH=~/.npm-global/bin:$PATH
