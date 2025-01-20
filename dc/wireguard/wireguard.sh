#!/bin/sh

# apt install wireguard

wg genkey | tee wg-mini-private.key |  wg pubkey > wg-mini-public.key
wg genkey | tee wg-server-srv2-prv.key |  wg pubkey > wg-server-srv2-pub.key

wg genkey | tee wg-alex-private.key |  wg pubkey > wg-alex-public.key


# sudo wg-quick up wg0


-----------
apt/dnf install qrencode

qrencode -t ansiutf8 -r wg.conf
qrencode -t png -o file_with_qr.png -r wg.conf
