#!/bin/sh

# apt install wireguard

wg genkey | tee wg-mini-private.key |  wg pubkey > wg-mini-public.key
wg genkey | tee wg-server-srv2-prv.key |  wg pubkey > wg-server-srv2-pub.key

wg genkey | tee wg-mobile-private.key |  wg pubkey > wg-mobile-public.key


# sudo wg-quick up wg0
