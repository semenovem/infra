#!/bin/bash

mkdir ~/.global-modules
npm config set prefix "~/.global-modules"
export PATH=~/.global-modules/bin:$PATH