#!/bin/bash

exit

# TODO сделать crone бекапирование
cd /mnt/dat_vol
sudo tar zcf - pihole/ | ssh -p 2022 forwardman@home.evgio.com "cat > /mnt/vol_backup_1/mini47/pihole-20240423.tar.gz"
