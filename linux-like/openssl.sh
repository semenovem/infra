#!/bin/bash


exit


openssl x509 -purpose -in cacert.pem -inform PEM


#----------
# не работает при переносе между версиями macos | linux
# -a (-base64) создать данные с кодировкой base64
openssl enc -aes-256-cbc -iter 100000 -in source -out target
openssl enc -aes-256-cbc -d -iter 100000 -in source -out target
