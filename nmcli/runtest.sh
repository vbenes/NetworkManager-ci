#!/bin/bash
set -x

logger -t $0 "Running test $1"

if [ -e /tmp/nm_newveth_configured ]; then
    # we must keep this device up in any case it went down
    nmcli con up testeth0
    # possible auto created duplicate profile. that we do not want
    nmcli con del eth0
fi

if [ ! -e /tmp/nm_eth_configured ]; then
    #set the root password to 'redhat' (for overcoming polkit easily)
    echo "Setting root password to 'redhat'"
    echo "redhat" | passwd root --stdin

    #adding ntp and syncing time
    yum -y install ntp tcpdump NetworkManager-libreswan
    service ntpd restart
    sleep 10

    #pull in debugging symbols
    cat /proc/$(pidof NetworkManager)/maps | awk '/ ..x. / {print $NF}' |
        grep '^/' | xargs rpm -qf | grep -v 'not owned' | sort | uniq |
        xargs debuginfo-install -y

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

    #making sure all wifi devices are named wlanX
    NUM=0
    wlan=0
    for DEV in `nmcli device | grep wifi | awk {'print $1'}`; do
        wlan=1
        ip link set $DEV down
        ip link set $DEV name wlan$NUM
        ip link set wlan$NUM up
        NUM=$(($NUM+1))
    done

    #installing behave and pexpect
    yum -y install install/*.rpm

    echo $1
    dcb_inf_wol=0
    if [[ $1 == *dcb_* ]]; then
        dcb_inf_wol=1
    fi
    if [[ $1 == *inf_* ]]; then
        dcb_inf_wol=1
    fi
    if [[ $1 == *wol_* ]]; then
        dcb_inf_wol=1
    fi

    veth=0
    if [ $wlan -eq 0 ]; then
        if [ $dcb_inf_wol -eq 0 ]; then
            for X in $(seq 0 10); do
                if ! nmcli -f DEVICE -t device |grep eth${X}; then
                    veth=1
                    break
                fi
            done
        fi
    fi


    if [ $veth -eq 1 ]; then
        sh vethsetup.sh setup

        touch /tmp/nm_newveth_configured

    else
        #profiles tuning
        if [ $wlan -eq 0 ]; then
            if [ $dcb_inf_wol -eq 0 ]; then
                nmcli connection add type ethernet ifname eth0 con-name testeth0
                nmcli connection delete eth0
                #nmcli connection modify testeth0 ipv6.method ignore
                nmcli connection up id testeth0
                nmcli con show -a
                for X in $(seq 1 10); do
                    nmcli connection add type ethernet con-name testeth$X ifname eth$X autoconnect no
                    nmcli connection delete eth$X
                done
                nmcli connection modify testeth10 ipv6.method auto
            fi
        fi
        if [ $wlan -eq 1 ]; then
            # we need to do this to have the device rescan networks after the renaming
            service NetworkManager restart
            # obtain valid certificates
            mkdir /tmp/certs
            wget http://wlan-lab.eng.bos.redhat.com/certs/eaptest_ca_cert.pem -O /tmp/certs/eaptest_ca_cert.pem
            wget http://wlan-lab.eng.bos.redhat.com/certs/client.pem -O /tmp/certs/client.pem
        fi

    fi

    # grep 'debug=fatal-warnings' /etc/NetworkManager/NetworkManager.conf

    # if [ "$?" == "1" ]; then
    #     sed -i 's/\[main\]/\[main\]\ndebug=fatal-warnings/' /etc/NetworkManager/NetworkManager.conf
    # fi

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
        DEV_MASTER=$(nmcli -t -f DEVICE device  |grep -o .*ib0$)
        echo $DEV_MASTER
        for VLAN in $(nmcli -t -f DEVICE device  |grep ib0 | awk 'BEGIN {FS = "."} {print $2}'); do
            DEV="$DEV_MASTER.$VLAN"
            NEW_DEV="inf_ib0.$VLAN"
            ip link set $DEV down
            sleep 1
            ip link set $DEV name $NEW_DEV
            ip link set $NEW_DEV up
            nmcli con del $DEV
        done
        ip link set $DEV_MASTER down
        sleep 1
        ip link set $DEV_MASTER name inf_ib0
        ip link set inf_ib0 up
        nmcli con del $DEV_MASTER

        touch /tmp/inf_configured
    fi
fi

# set TEST variable for version_control script
if [ -z "$TEST" ]; then
    TEST="NetworkManager_Test0_$1"
fi

#check if NM version is correct for test
TAG=$(python version_control.py nmcli $TEST); vc=$?
if [ $vc -eq 1 ]; then
    echo "Skipping due to incorrect NM version for this test"
    # exit 0 doesn't affect overal result
    exit 0

elif [ $vc -eq 0 ]; then
    if [ x$TAG != x"" ]; then
        echo "Running $TAG version of $TEST"
        behave nmcli/features -t $1 -t $TAG -k -f html -o /tmp/report_$TEST.html -f plain; rc=$?
    else
        behave nmcli/features -t $1 -k -f html -o /tmp/report_$TEST.html -f plain; rc=$?
    fi
fi

RESULT="FAIL"
if [ $rc -eq 0 ]; then
    RESULT="PASS"
fi

rhts-report-result $TEST $RESULT "/tmp/report_$TEST.html"
#rhts-submit-log -T $TEST -l "/tmp/log_$TEST.html"

logger -t $0 "Test $1 finished with result $RESULT: $rc"

echo "------------ Test result: $RESULT ------------"
exit $rc
