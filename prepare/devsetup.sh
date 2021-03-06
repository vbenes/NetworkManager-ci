#!/bin/bash

local_setup_configure_nm_eth () {
    [ -e /tmp/nm_eth_configured ] && return

    #set the root password to 'networkmanager' (for overcoming polkit easily)
    echo "Setting root password to 'networkmanager'"
    echo "networkmanager" | passwd root --stdin

    echo "Setting test's password to 'networkmanager'"
    userdel -r test
    useradd -m test
    echo "networkmanager" | passwd test --stdin

    #adding ntp and syncing time
    yum -y install dnsmasq ntp tcpdump NetworkManager-libreswan wireshark bridge-utils

    service ntpd restart

    #pull in debugging symbols
    if [ ! -e /tmp/nm_no_debug ]; then
        cat /proc/$(pidof NetworkManager)/maps | awk '/ ..x. / {print $NF}' |
            grep '^/' | xargs rpm -qf | grep -v 'not owned' | sort | uniq |
            xargs debuginfo-install -y
    fi

    #restart with valgrind
    if [ -e /etc/systemd/system/NetworkManager-valgrind.service ]; then
        ln -s NetworkManager-valgrind.service /etc/systemd/system/NetworkManager.service
        systemctl daemon-reload
    elif [[      -e /etc/systemd/system/NetworkManager.service.d/override.conf-strace
            && ! -e /etc/systemd/system/NetworkManager.service.d/override.conf ]]; then
        ln -s override.conf-strace /etc/systemd/system/NetworkManager.service.d/override.conf
        systemctl daemon-reload
    fi

    #removing rate limit for systemd journaling
    sed -i 's/^#\?\(RateLimitInterval *= *\).*/\10/' /etc/systemd/journald.conf
    sed -i 's/^#\?\(RateLimitBurst *= *\).*/\10/' /etc/systemd/journald.conf
    sed -i 's/^#\?\(SystemMaxUse *= *\).*/\115G/' /etc/systemd/journald.conf
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

    # Give proper context to openvpn profiles
    chcon -R system_u:object_r:usr_t:s0 tmp/openvpn/sample-keys/

    #making sure all wifi devices are named wlanX
    NUM=0
    wlan=0
    if ! rpm -q --quiet NetworkManager-wifi; then
        yum -y install NetworkManager-wifi
    fi
    for DEV in `nmcli device | grep wifi | awk {'print $1'}`; do
        wlan=1
        ip link set $DEV down
        ip link set $DEV name wlan$NUM
        ip link set wlan$NUM up
        NUM=$(($NUM+1))
    done

    #installing behave and pexpect
    yum -y install https://kojipkgs.fedoraproject.org//packages/python-behave/1.2.5/18.el7/noarch/python2-behave-1.2.5-18.el7.noarch.rpm https://kojipkgs.fedoraproject.org//packages/python-parse/1.6.4/4.el7/noarch/python-parse-1.6.4-4.el7.noarch.rpm https://kojipkgs.fedoraproject.org//packages/python-parse_type/0.3.4/6.el7/noarch/python-parse_type-0.3.4-6.el7.noarch.rpm
    yum -y install pexpect

    echo $1
    dcb_inf_wol_sriov=0
    if [[ $1 == *sriov_* ]]; then
        dcb_inf_wol_sriov=1
    fi
    if [[ $1 == *dcb_* ]]; then
        dcb_inf_wol_sriov=1
    fi
    if [[ $1 == *inf_* ]]; then
        dcb_inf_wol_sriov=1
    fi
    if [[ $1 == *wol_* ]]; then
        dcb_inf_wol_sriov=1
    fi

    if [ $dcb_inf_wol_sriov -eq 1 ]; then
        touch /tmp/nm_dcb_inf_wol_sriov_configured
    fi

    veth=0
    if [ $wlan -eq 0 ]; then
        if [ $dcb_inf_wol_sriov -eq 0 ]; then
            for X in $(seq 0 10); do
                if ! nmcli -f DEVICE -t device |grep eth${X}; then
                    veth=1
                    break
                fi
            done
        fi
    fi


    if [ $veth -eq 1 ]; then
        sh prepare/vethsetup.sh setup

        touch /tmp/nm_newveth_configured

    else
        #profiles tuning
        if [ $wlan -eq 0 ]; then
            if [ $dcb_inf_wol_sriov -eq 0 ]; then
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

            # THIS NEED TO BE DONE HERE AS DONE SEPARATELY IN VETHSETUP FOR RECREATION REASONS
            nmcli c modify testeth0 ipv4.route-metric 99 ipv6.route-metric 99
            sleep 1
            # Copy final connection to /tmp/testeth0 for later in test usage
            yes 2>/dev/null | cp -rf /etc/sysconfig/network-scripts/ifcfg-testeth0 /tmp/testeth0

            yum -y install NetworkManager-config-server
            #cp /usr/lib/NetworkManager/conf.d/00-server.conf /etc/NetworkManager/conf.d/00-server.conf
        fi

        if [ $wlan -eq 1 ]; then
            # obtain valid certificates
            mkdir /tmp/certs
            wget http://wlan-lab.eng.bos.redhat.com/certs/eaptest_ca_cert.pem -O /tmp/certs/eaptest_ca_cert.pem
            wget http://wlan-lab.eng.bos.redhat.com/certs/client.pem -O /tmp/certs/client.pem
            touch /tmp/nm_wifi_configured
        fi
    fi

    systemctl stop firewalld
    systemctl mask firewalld

    nmcli c u testeth0


    systemctl restart NetworkManager
    sleep 10
    nmcli con up testeth0; rc=$?
    if [ $rc -ne 0 ]; then
        sleep 20
        nmcli con up testeth0
    fi
    touch /tmp/nm_eth_configured
}

local_setup_configure_nm_dcb () {
    [ -e /tmp/dcb_configured ] && return

    #start dcb modules
    yum -y install lldpad fcoe-utils
    systemctl enable fcoe
    systemctl start fcoe
    systemctl enable lldpad
    systemctl start lldpad

    modprobe -r ixgbe; modprobe ixgbe
    sleep 2
    dcbtool sc p6p2 dcb on

    touch /tmp/dcb_configured
}

local_setup_configure_nm_inf () {
    [ -e /tmp/inf_configured ] && return

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
}

local_setup_configure_nm_gsm () {
    [ -e /tmp/gsm_configured ] && return

    mkdir /mnt/scratch
    mount -t nfs nest.test.redhat.com:/mnt/qa/desktop/broadband_lock /mnt/scratch

    yum -y install NetworkManager-wwan ModemManager usb_modeswitch usbutils NetworkManager-ppp
    systemctl restart ModemManager
    sleep 60
    systemctl restart NetworkManager
    sleep 120

    touch /tmp/gsm_configured
}


setup_configure_environment () {
    local_setup_configure_nm_eth "$1"
    case "$1" in
        *dcb_*)
            local_setup_configure_nm_dcb
            ;;
        *inf_*)
            local_setup_configure_nm_inf
            ;;
        *gsm*)
            local_setup_configure_nm_gsm
            ;;
    esac
}
