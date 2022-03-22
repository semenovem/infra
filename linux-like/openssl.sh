#!/bin/bash


exit


openssl x509 -purpose -in cacert.pem -inform PEM


#----------
# не работает при переносе между версиями macos | linux
# -a (-base64) создать данные с кодировкой base64
openssl enc -aes-256-cbc -iter 100000 -in source -out target
openssl enc -aes-256-cbc -d -iter 100000 -in source -out target

openssl ecparam -list_curves

#------------
# encrypt / decrypt
openssl aes-256-cbc -a -salt -in file.txt -out file.txt.enc
openssl aes-256-cbc -d -a -in file.txt.enc -out file.txt.new
