#! /bin/bash
set -x

nmcli dev disconnect eth0
nmcli con del testeth0
sleep 1
nmcli connection add type ethernet ifname eth0 con-name testeth0
nmcli connection modify testeth0 ipv6.may-fail no
nmcli con up id testeth0
ip a s eth0
ip -6 r
sleep 60

systemctl condreload beah-beaker-backend.service

sleep 60

exit 0
