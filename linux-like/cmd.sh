#!/bin/bash

exit 0

sudo apt-get install lm-sensors
sensors

# fix trouble of locales
localedef -i en_US -f UTF-8 en_US.UTF-8


# DNS lookup utility
dig evgio.dev
