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

    #installing behave and pexpect
    yum -y install install/*.rpm

    #profiles tuning
    nmcli connection modify eth0 ipv6.method auto
    nmcli connection down id eth0
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
    service NetworkManager restart

    touch /tmp/nm_eth_configured
fi

#rhts-run-simple-test "$TEST" "behave ipv4/features -t $1 -k -f html -o /tmp/report_$TEST.html -f plain"; rc=$?
behave nmcli/ipv4/features -t $1 -k -f html -o /tmp/report_$TEST.html -f plain; rc=$?
#pkill -u test -f dbus-daemon
#rhts-submit-log -l "/tmp/report_$TEST.html"
RESULT=FAIL
if [ $rc -eq 0 ]; then
  RESULT="PASS"
else
    nmcli con
    #ip a s
    cp -f "/var/log/messages" /tmp/$TEST-messages
    rhts-submit-log -l "/tmp/$TEST-messages"
fi

rhts-report-result $TEST $RESULT "/tmp/report_$TEST.html"
echo "------------ Test result: $RESULT ------------"
exit $rc