

# https://smb-conf.ru/
# https://1cloud.ru/help/network/nastroika-samba-v-lokalnoj-seti

exit

sudo apt install samba smbclient


testparm -s
service smbd restart
