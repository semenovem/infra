#!/bin/bash


exit 0


sudo apt-get upgrade

sudo apt-get update
sudo apt-get install squid squid-common
sudo service squid start


sudo service squid restart


# squid
# port 26824


