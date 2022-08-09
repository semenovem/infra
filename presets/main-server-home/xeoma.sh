#!/bin/bash
exit 0


# 10090  - web server
# 10080  - connect for clients


# - лицензии
# https://felenasoft.com/xeoma/ru/support/activation-issues/

# - linux commands
# https://felenasoft.com/xeoma/ru/help/commands/

# - for linux man
# https://felenasoft.com/xeoma/ru/articles/linux-video-surveillance/


# port for remote client 11067
./xeoma -serverport 10080  # server port
./xeoma -setpassword [Password] # server password

# or
./xeoma -enableconwithoutpass [UserName]

# показать пароль и включить удалённый доступ
-showpassword

# путь до директории хранения кэша архива
# (желательно на RAM-диске или скоростном HDD) для увеличения скорости записи**
-archivecache [DirPath]
