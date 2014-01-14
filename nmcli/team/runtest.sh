#!/bin/bash

if [ ! -e /tmp/nm_eth_configured ]; then
    #set the root password to 'redhat' (for overcoming polkit easily)
    echo "Setting root password to 'redhat'"
    echo "redhat" | passwd root --stdin

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
    #yum -y install wireshark teamd bash-completion
    #git clone git://github.com/roignac/behave
    #cd behave
    #git checkout html_formatter
    #python setup.py install
    #cd ..
    #yum -y localinstall http://kojipkgs.fedoraproject.org//packages/python-parse/1.6.2/4.fc19/noarch/python-parse-1.6.2-4.fc19.noarch.rpm http://kojipkgs.fedoraproject.org//packages/python-behave/1.2.3/8.fc19/noarch/python-behave-1.2.3-8.fc19.noarch.rpm
    #easy_install pip
    #pip install pexpect

    #profiles tuning

    nmcli connection modify eth0 ipv6.method auto
    nmcli connection modify eth1 connection.autoconnect no
    nmcli connection modify eth2 connection.autoconnect no

    service NetworkManager restart

    touch /tmp/nm_eth_configured

fi

#rhts-run-simple-test "$TEST" "behave ipv4/features -t $1 -k -f html -o /tmp/report_$TEST.html -f plain"; rc=$?
behave nmcli/team/features -t $1 -k -f html -o /tmp/report_$TEST.html -f plain; rc=$?
#pkill -u test -f dbus-daemon
#rhts-submit-log -l "/tmp/report_$TEST.html"
RESULT=FAIL
if [ $rc -eq 0 ]; then
  RESULT="PASS"
else
    nmcli con
    ip a s
fi
rhts-report-result $TEST $RESULT "/tmp/report_$TEST.html"
