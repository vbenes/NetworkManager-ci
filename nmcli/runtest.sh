#!/bin/bash
set -x

logger -t $0 "Running test $1"

if [ -e /tmp/nm_veth_configured ]; then
    # check if macs aren't the same again
    if [ `ip a s par0 |grep link/ether | awk '{print $2}'` == `ip a s eth0 |grep link/ether | awk '{print $2}'` ]; then
        macaddr=$(echo $(hostname)|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')
        ip link set dev par0 address $macaddr
    fi

    if ! nmcli con s -a |grep dhcp-srv; then
        ip link set dev eth99 up
        ip link set dev eth99p up
        nmcli c up id dhcp-srv
        sleep 2
    fi

    if ! nmcli con s dhcp-srv |grep 192.168.100.1; then
        nmcli con mod dhcp-srv ipv4.addresses 192.168.100.1/24 ipv4.method shared
        nmcli c up id dhcp-srv
    fi

    if ! nmcli con s -a |grep par0_out; then
        nmcli con up par0_out
    fi

    if ! nmcli con s -a |grep testeth0; then
        ip link set dev eth0 up address $(cat /tmp/nm_orig_mac)
        ip link set dev eth0p up
        nmcli con up testeth0
    fi
fi

if [ ! -e /tmp/nm_eth_configured ]; then
    #set the root password to 'redhat' (for overcoming polkit easily)
    echo "Setting root password to 'redhat'"
    echo "redhat" | passwd root --stdin

    #set the anti-colors wrapper (should be temporary solution)
    mv /usr/bin/nmcli /usr/bin/nmcli_colors
    cp ./wrapper /usr/bin/nmcli
    hash -r

    #adding ntp and syncing time
    yum -y install ntp tcpdump
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
    dcb_inf=0
    if [[ $1 == *dcb_* ]]; then
        dcb_inf=1
    fi
    if [[ $1 == *inf_* ]]; then
        dcb_inf=1
    fi

    veth=0
    if [ $wlan -eq 0 ]; then
        if [ $dcb_inf -eq 0 ]; then
            for X in $(seq 0 10); do
                if ! nmcli -f DEVICE -t device |grep eth${X}; then
                    veth=1
                    break
                fi
            done
        fi
    fi


    if [ $veth -eq 1 ]; then
       # to prevent "Wired Connection X" mess
        if ! grep no-auto-default /etc/NetworkManager/NetworkManager.conf; then
            echo "no-auto-default=*" >> /etc/NetworkManager/NetworkManager.conf
            echo "ignore-carrier=*" >> /etc/NetworkManager/NetworkManager.conf
            service NetworkManager restart
        fi
        sleep 5

        NUM=0
        # renaming all possible device to parX
        for DEV in $(nmcli -f TYPE,DEVICE -t c sh -a  | grep ethernet | awk '{split($0,a,":"); print a[2]}'); do
            #if [ "$DEV" == "$(ip route |grep default |awk '{print $5}')" ]; then
            ip link set $DEV down
            ip link set $DEV name par$NUM
            ip link set par$NUM up
            nmcli c add type ethernet con-name par$NUM ifname par$NUM autoconnect no
            nmcli c down par$NUM
            nmcli c del $DEV
            #else
            #    ip link set $DEV down
            #fi
            ((NUM++))
        done

        # clonning mac address of original master device to new eth0
        orig_macaddr=$(ip a s par0 |grep link/ether | awk '{print $2}')
        #ip link set dev eth0 address $orig_macaddr
        echo $orig_macaddr > /tmp/nm_orig_mac
        macaddr=$(echo $(hostname)|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')
        ip link set dev par0 address $macaddr

        # removing all possible devices
        for X in $(seq 0 10); do
            nmcli c delete id eth${X}
            ip link set dev eth${X} down
        done

        # creating eth99 device
        ip link add eth99 type veth peer name eth99p

        # adding bridge and connecting eth99 peer inside
        brctl addbr isobr
        ip link set dev isobr up
        brctl addif isobr eth99p

        # creating shared profile (dnsmasq dhcp server)
        nmcli c add type ethernet con-name dhcp-srv autoconnect no ifname eth99
        nmcli c modify dhcp-srv ipv4.method shared
        nmcli c modify dhcp-srv ipv4.addresses 192.168.100.1/24

        # starting devices
        ip link set eth99 up
        ip link set eth99p up

        # starting NM profile
        nmcli c up id dhcp-srv

        # creating 8 virtual devices and adding peers into bridge
        for X in $(seq 1 9); do
            ip link add eth${X} type veth peer name eth${X}p
            brctl addif isobr eth${X}p
        done

        # creating 8 NM profiles and starting them
        for X in $(seq 1 9); do
            nmcli c add type ethernet con-name testeth${X} ifname eth${X} autoconnect no
            ip link set eth${X} up
            ip link set eth${X}p up
        done

        # creating eth0 and eth10 devices and peers
        ip link add eth0 addr $orig_macaddr type veth peer name eth0p
        ip link add eth10 type veth peer name eth10p


        # adding bridge and connecting eth0 and eth10 peers inside
        brctl addbr outbr
        ip link set dev outbr up
        nmcli connection add type bridge-slave ifname par0 con-name par0_out master outbr
        nmcli connection modify par0_out 802-3-ethernet.cloned-mac-address $(echo $(hostname)|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')
        brctl addif outbr eth0p
        brctl addif outbr eth10p

        # creating 2 NM profiles and starting them
        nmcli c add type ethernet con-name testeth0 ifname eth0 autoconnect yes
        nmcli c add type ethernet con-name testeth10 ifname eth10 autoconnect no

        for X in 0 10; do
            ip link set eth${X} up
            ip link set eth${X}p up
        done
        nmcli c up id testeth0

        sleep 10
        touch /tmp/nm_veth_configured

    else
        #profiles tuning
        if [ $wlan -eq 0 ]; then
            if [ $dcb_inf -eq 0 ]; then
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
        nmcli dev disconnect mlx4_ib1.8005
        sleep 5
        nmcli connection delete mlx4_ib1
        nmcli connection delete mlx4_ib1.8005
        sleep 5

        touch /tmp/inf_configured
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

rhts-report-result $TEST $RESULT "/tmp/report_$TEST.html"
#rhts-submit-log -T $TEST -l "/tmp/log_$TEST.html"

logger -t $0 "Test $1 finished with result $RESULT: $rc"

echo "------------ Test result: $RESULT ------------"
exit $rc
