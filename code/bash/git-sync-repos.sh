#!/bin/bash

IFS='.'

cd /home/git/moved

for dir in /home/git/*.git/;do
    dir=${dir%*/}
    read -ra SPLIT <<< "${dir##*/}"
    repo="${SPLIT[0]}"
    rm -Rf "./${repo}"
    ./clone "${repo}"
    ./push "${repo}"
    ./pull "${repo}"
done
