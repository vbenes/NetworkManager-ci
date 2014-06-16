#!/bin/bash
set -x

if [ ! -e /tmp/nmcli_testing_configured ]; then
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

    #making sure all ethernet devices are named ethX
    NUM=0
    for DEV in `nmcli device | grep connected | grep ethernet | awk {'print $1'}`; do
	ip link set $DEV down
    mv /etc/sysconfig/network-scripts/ifcfg-$DEV /etc/sysconfig/network-scripts/ifcfg-eth$NUM
    #echo "NM_CONTROLLED=no" >> /etc/sysconfig/network-scripts/ifcfg-eth$NUM
	ip link set $DEV name eth$NUM
	ip link set eth$NUM up
	NUM=$(($NUM+1))
    done

    #making sure all wifi devices are named wlanX
    NUM=0
    for DEV in `nmcli device | grep wifi | awk {'print $1'}`; do
    ip link set $DEV down
    ip link set $DEV name wlan$NUM
    ip link set wlan$NUM up
    NUM=$(($NUM+1))
    done

    #installing packages needed for wifi and behave (no outside-world connectivity in lab)

    #yum -y install install/iw*rpm
    #yum -y install install/pexpect*rpm
    #yum -y install install/behave*rpm
    yum -y install install/*.rpm
    #yum -y install install/net-tools*rpm

    cp -r certs/ /tmp/ #certificates needed for wifi-sec tests

    touch /tmp/nmcli_testing_configured
    nmcli connection down id eth0
    service NetworkManager restart
    sleep 10
fi

#rhts-run-simple-test "$TEST" "behave ipv4/features -t $1 -k -f html -o /tmp/report_$TEST.html -f plain"; rc=$?
#behave nmcli/features -t $1 -k -f plain -o /tmp/report_$TEST.log -f plain; rc=$?
behave nmcli/supreme/features -t $1 -k -o /tmp/report_$TEST.log; rc=$?
#pkill -u test -f dbus-daemon
#rhts-submit-log -l "/tmp/report_$TEST.html"
RESULT="FAIL"
if [ $rc -eq 0 ]; then
    RESULT="PASS"
fi

#echo "--------- /tmp/report_$TEST.log ---------"
#cat /tmp/report_$TEST.log

NAME=$(find . -name *.feature | xargs cat | awk "/$TEST/{getline; print}" | sed -E "s/.*Scenario:\s?(.*).*/\\1/" | tr " " _)

rhts-report-result $TEST $RESULT "/tmp/report_$TEST.log"
echo "------------ Test result: $RESULT ------------"
exit $rc
