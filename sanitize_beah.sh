#! /bin/bash
set -x
nmcli con down testeth0
sleep 2
nmcli con up testeth0

# sudo sysctl net.ipv6.conf.all.disable_ipv6=1
# sudo sysctl net.ipv6.conf.all.disable_ipv6=0

# nmcli dev disconnect eth0
# nmcli con del testeth0
# sleep 2
# systemctl restart NetworkManager
# nmcli connection add type ethernet ifname eth0 con-name testeth0
# nmcli con up testeth0
# sleep 60
# ip a s eth0
# ip -6 r

# sudo kill -9 $(ps aux|grep -v grep| grep beah-beaker-backend |awk '{print $2}')
# sudo /usr/bin/python /usr/bin/beah-beaker-backend --log-stderr &
# sleep 120

exit 0

