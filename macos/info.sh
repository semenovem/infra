
exit

# install https://brew.sh/
# todo linux-like/get_started.md
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"



### mount remote directory via ssh
# https://osxfuse.github.io/

# https://github.com/osxfuse/sshfs
# https://github.com/osxfuse/sshfs/releases


# execute
sshfs evg@192.168.1.8:/ ~/_mount

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
# Список сетей
/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -s
