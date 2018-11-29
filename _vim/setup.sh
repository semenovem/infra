#!/bin/bash

FILE="~/.vimrc"

if [ ! -f ~/.vimrc ]; then
    echo "Файл $FILE не существует"
    cp ./vimrc ~/.vimrc
    exit 0
fi


