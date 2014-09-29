#!/bin/bash
set -x

if [ ! -e /tmp/nm_eth_configured ]; then
    #set the root password to 'redhat' (for overcoming polkit easily)
    echo "Setting root password to 'redhat'"
    echo "redhat" | passwd root --stdin

    #adding ntp and syncing time
    yum -y install ntp
    service ntpd restart
    sleep 10

    #removing rate limit for systemd journaling
    sed -i 's/^#\?\(RateLimitInterval *= *\).*/\10/' /etc/systemd/journald.conf
    sed -i 's/^#\?\(RateLimitBurst *= *\).*/\10/' /etc/systemd/journald.conf
    systemctl restart systemd-journald.service

    #fake console
    echo "Faking a console session..."
    touch /run/console/test
    echo test > /run/console/console.lock

    #passwordless sudo
    echo "enabling passwordless sudo"
    if [ -e /etc/sudoers.bak ]; then
    mv -f /etc/sudoers.bak /etc/sudoers
    fi
    cp -a /etc/sudoers /etc/sudoers.bak
    grep -v requiretty /etc/sudoers.bak > /etc/sudoers
    echo 'Defaults:test !env_reset' >> /etc/sudoers
    echo 'test ALL=(ALL)   NOPASSWD: ALL' >> /etc/sudoers

    #setting ulimit to unlimited for test user
    echo "ulimit -c unlimited" >> /home/test/.bashrc

    #prepare beah not to use IPv6
    #sed -i s/\#DEVEL=True/IPV6_DISABLED=True/  /etc/beah.conf
    #sudo kill -9 $(ps aux|grep -v grep| grep /usr/bin/beah-beaker-backend |awk '{print $2}')
    #beah-beaker-backend &

    #installing behave and pexpect
    yum -y install install/*.rpm

    #profiles tuning
    nmcli connection down id eth0
    nmcli connection modify eth0 ipv6.method ignore
    nmcli connection modify eth1 connection.autoconnect no
    nmcli connection modify eth2 connection.autoconnect no
    nmcli connection modify eth3 connection.autoconnect no
    nmcli connection modify eth4 connection.autoconnect no
    nmcli connection modify eth5 connection.autoconnect no
    nmcli connection modify eth6 connection.autoconnect no
    nmcli connection modify eth7 connection.autoconnect no
    nmcli connection modify eth8 connection.autoconnect no
    nmcli connection modify eth9 connection.autoconnect no
    nmcli connection modify eth10 connection.autoconnect no
    nmcli connection modify eth10 ipv6.method auto
    service NetworkManager restart

    touch /tmp/nm_eth_configured
fi

if [[ $1 == *dcb_* ]]; then
    if [ ! -e /tmp/dcb_configured ]; then
        #start dcb modules
        yum -y install lldpad fcoe-utils
        systemctl enable fcoe
        systemctl start fcoe
        systemctl enable lldpad
        systemctl start lldpad

        dcbtool sc enp4s0f0 dcb on

        touch /tmp/dcb_configured
    fi
fi

if [[ $1 == *inf_* ]]; then
    if [ ! -e /tmp/inf_configured ]; then
        nmcli dev disconnect mlx4_ib1
        nmcli dev disconnect mlx4_ib1.8003
        sleep 5
        nmcli connection delete mlx4_ib1
        nmcli connection delete mlx4_ib1.8003
        sleep 5
        service NetworkManager restart

        touch /tmp/inf_configured
    fi
fi

if [[ $1 == *alias_* ]]; then
    if [ ! -e /tmp/alias_configured ]; then
        nmcli connection delete eth7

        touch /tmp/alias_configured
    fi
fi

behave nmcli/features -t $1 -k -f html -o /tmp/report_$TEST.html -f plain; rc=$?

RESULT=FAIL
if [ $rc -eq 0 ]; then
  RESULT="PASS"
else
    nmcli con
    ip a s
fi

rhts-report-result $TEST $RESULT -l "/tmp/report_$TEST.html"
rhts-submit-log -T $TEST -l "/tmp/log_$TEST.html"

echo "------------ Test result: $RESULT ------------"
exit $rc