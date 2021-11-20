#!/bin/bash

mkdir ~/.npm-global
npm config set prefix "~/.npm-global"
export PATH=~/.npm-global/bin:$PATH



ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

#
brew install gnupg
