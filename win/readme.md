


https://www.microsoft.com/ru-ru/software-download/windows10


# Подготовка образа
# on macos 
diskutil list

# for example /dev/disk3
sudo diskutil eraseDisk FAT32 WININSTALL MBRFormat /dev/disk3

# mount iso

# copy to flash
cp -R iso usb

# ---------------------------------
# ---------------------------------]


# Скрипт вызова экрана блокировки
Set objShell = CreateObject("Shell.Application")
objShell.WindowsSecurity


# restart / shutdown
C:\Windows\System32\shutdown.exe -r -t 0
C:\Windows\System32\shutdown.exe -s -t 0


# off password on startup screen
netplwiz
