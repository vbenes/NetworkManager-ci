# -*- coding: UTF-8 -*-

import os
import pexpect
from subprocess import call, Popen, check_output
from time import sleep, localtime, strftime


TIMER = 0.5

# the order of these steps is as follows
# 1. before scenario
# 2. before tag
# 3. after scenario
# 4. after tag

def before_scenario(context, scenario):
    try:
        context.log = file('/tmp/log_%s.html' % scenario.name,'w')
        context.log_start_time = strftime("%Y-%m-%d %H:%M:%S", localtime())
    except Exception as e:
        print("Error in before_scenario: %s" % e.message)

def before_tag(context, tag):
    if tag == 'veth':
        if os.path.isfile('/tmp/nm_veth_configured'):
            import sys
            sys.exit(0)

    if tag == 'eth0':
        print "---------------------------"
        print "eth0 disconnect"
        call("nmcli con down testeth0", shell=True)
        call('nmcli con down testeth1', shell=True)
        call('nmcli con down testeth2', shell=True)

    if tag == 'alias':
        print "---------------------------"
        print "deleting eth7 connections"
        call("nmcli connection up testeth7", shell=True)
        call("nmcli connection delete eth7", shell=True)

    if tag == "firewall":
        print "---------------------------"
        print "starting firewall"
        call("sudo yum -y install firewalld", shell=True)
        call("sudo systemctl unmask firewalld", shell=True)
        call("sudo systemctl start firewalld", shell=True)
        #call("sleep 4", shell=True)

    if tag == "tshark":
        print "---------------------------"
        print "ip link up eth10 connection"
        if os.path.isfile('/tmp/nm_veth_configured'):
            call("ip link set dev eth10 up", shell=True)
            call("ip link set dev eth0p up", shell=True)


    if (tag == 'ethernet') or (tag == 'bridge') or (tag == 'vlan'):
        print "---------------------------"
        print "sanitizing eth1 and eth2"
        #call("for dev in $(nmcli device status |grep -v eth0 |grep -e ' connected' |awk {'print $1'}); do sudo nmcli device disconnect $dev; done", shell=True)
        #if call("nmcli device status |grep -v eth0 |grep -e ' connected'", shell=True) != 1:
        #    call("for dev in $(nmcli device status |grep -v eth0 |grep -e ' connected' |awk {'print $1'}); do sudo nmcli device disconnect $dev; done", shell=True)

        call('sudo nmcli con del testeth1 testeth2', shell=True)
        call('sudo nmcli con add type ethernet ifname eth1 con-name testeth1 autoconnect no', shell=True)
        #call('sudo ifup eth1', shell=True)
        call('sudo nmcli con add type ethernet ifname eth2 con-name testeth2 autoconnect no', shell=True)
        #call('sudo ifup eth2', shell=True)
        call('sudo nmcli con down testeth1', shell=True)
        call('sudo nmcli con down testeth2', shell=True)

    if tag == 'vlan' or tag == 'bridge':
        print "---------------------------"
        print "connecting eth1"
        if os.path.isfile('/tmp/nm_veth_configured'):
            call("ip link set dev eth1 up", shell=True)
            call("ip link set dev eth1p up", shell=True)
            sleep(1)
        call("nmcli connection up testeth1", shell=True)

    if tag == 'bond' or tag == 'team':
        print "---------------------------"
        print "ip upping eth1/eth2"
        if os.path.isfile('/tmp/nm_veth_configured'):
            call("ip link set dev eth1 up", shell=True)
            call("ip link set dev eth2 up", shell=True)
            call('nmcli con up testeth1', shell=True)

    if tag == 'hostname_change':
        print "---------------------------"
        print "saving original hostname"
        context.original_hostname = check_output('cat /etc/hostname', shell=True).strip()

    if 'openvswitch' in tag:
        print "---------------------------"
        print "deleting eth1 and eth2 for openswitch tests"
        call('sudo nmcli con del eth1 eth2', shell=True) # delete these profile, we'll work with other ones


def after_step(context, step):
    """
    """
    pass
    #sleep(0.2)


def after_scenario(context, scenario):
    """
    """
    try:
        # Attach journalctl logs
        os.system("sudo journalctl -u NetworkManager --no-pager -o cat --since='%s' > /tmp/journal-nm.log" % context.log_start_time)
        data = open("/tmp/journal-nm.log", 'r').read()
        if data:
            context.embed('text/plain', data)

        if hasattr(context, "embed"):
            context.embed('text/plain', open("/tmp/log_%s.html" % scenario.name, 'r').read())

    except Exception as e:
        print("Error in after_scenario: %s" % e.message)

def after_tag(context, tag):
    """
    """
    if tag == 'ipv4':
        print "---------------------------"
        print "deleting connection ethie"
        call("nmcli connection delete id ethie", shell=True)
        #sleep(TIMER)

    if tag == 'ipv4_2':
        print "---------------------------"
        print "deleting connections ethie and ethie2"
        call("nmcli connection delete id ethie2", shell=True)
        call("nmcli connection delete id ethie", shell=True)
        #sleep(TIMER)

    if tag == 'alias':
        print "---------------------------"
        print "deleting alias connections"
        call("nmcli connection delete eth7", shell=True)
        call("sudo rm -f /etc/sysconfig/network-scripts/ifcfg-aliaseth7:0", shell=True)
        call("sudo rm -f /etc/sysconfig/network-scripts/ifcfg-aliaseth7:1", shell=True)
        call("sudo rm -f /etc/sysconfig/network-scripts/ifcfg-aliaseth7:2", shell=True)
        call("sudo nmcli connection reload", shell=True)
        #call('sudo nmcli con add type ethernet ifname eth7 con-name testeth7 autoconnect no', shell=True)
        #sleep(TIMER)

    if tag == "slaves":
        print "---------------------------"
        print "deleting slave profiles"
        call('nmcli connection delete id bond0.0 bond0.1 bond-slave-eth1', shell=True)
        #sleep(TIMER)

    if tag == "bond":
        print "---------------------------"
        print "deleting bond profile"
        call('nmcli connection delete id bond0 bond', shell=True)

        #sleep(TIMER)
        print os.system('ls /proc/net/bonding')

    if tag == "con":
        print "---------------------------"
        print "deleting connie"
        call("nmcli connection delete id connie", shell=True)
        #sleep(TIMER)

    if tag == "BBB":
        print "---------------------------"
        print "deleting BBB"
        call("nmcli connection delete id BBB", shell=True)
        #sleep(TIMER)

    if tag == "eth":
        print "---------------------------"
        print "deleting ethie"
        call("nmcli connection delete id ethie", shell=True)
        #sleep(TIMER)

    if tag == "firewall":
        print "---------------------------"
        print "stoppping firewall"
        call("sudo service firewalld stop", shell=True)
        #sleep(TIMER)

    if tag == 'ipv6_describe' or tag == 'testcase_304241':
        call('sudo kill -9 $(ps aux|grep -v grep| grep /usr/bin/beah-beaker-backend |awk \'{print $2}\')', shell=True)
        sleep(1)
        os.system('beah-beaker-backend &')
        sleep(20)

    if tag == "eth0":
        print "---------------------------"
        print "upping eth0"
        if os.path.isfile('/tmp/nm_veth_configured'):
            call("ip link set dev eth0 up address $(cat /tmp/nm_orig_mac)", shell=True)
            call("ip link set dev eth0p up", shell=True)

        call("nmcli connection up id testeth0", shell=True)
        sleep(2)

    if tag == "time":
        print "---------------------------"
        print "time connection delete"
        call("nmcli connection delete id time", shell=True)
        #sleep(TIMER)

    if tag == 'dcb':
        print "---------------------------"
        print "deleting connection dcb"
        call("nmcli connection down id dcb", shell=True)
        call("nmcli connection delete id dcb", shell=True)
        sleep(10*TIMER)

    if tag == 'inf':
        print "---------------------------"
        print "deleting infiniband connections"
        call("nmcli device disconnect mlx4_ib1", shell=True)
        call("nmcli device disconnect mlx4_ib1.8003", shell=True)
        call("nmcli connection delete id inf", shell=True)
        call("nmcli connection delete id infiniband-mlx4_ib1", shell=True)
        call("nmcli connection delete id inf.8003", shell=True)
        call("nmcli connection delete id infiniband-mlx4_ib1.8003", shell=True)
        sleep(10*TIMER)

    if tag == "profie":
        print "---------------------------"
        print "deleting profile profile"
        call("nmcli connection delete id profie", shell=True)
        #sleep(TIMER)

    if tag == "ipv6" or tag == "ipv6_2":
        print "---------------------------"
        print "deleting connections"
        if tag == "ipv6_2":
            call("nmcli connection delete id ethie2", shell=True)
        call("nmcli connection delete id ethie", shell=True)
        #sleep(TIMER)

    if tag == "team_slaves":
        print "---------------------------"
        print "deleting team slaves"
        call('nmcli connection delete id team0.0 team0.1 team-slave-eth2 team-slave-eth1', shell=True)
        #sleep(TIMER)

    if tag == "team":
        print "---------------------------"
        print "deleting team masters"
        call('nmcli connection delete id team0 team', shell=True)
        #sleep(TIMER)

    if tag == 'ethernet':
        print "---------------------------"
        print "removing ethernet profiles"
        call("sudo nmcli connection delete id ethernet ethos", shell=True)
        call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-ethernet*', shell=True) #ideally should do nothing

    if (tag == 'vlan') or (tag == 'bridge'):
        print "---------------------------"
        print "deleting all possible bridge residues"
        call('sudo nmcli con del vlan eth1.99 eth1.299 eth1.399 eth1.65 eth1.165 eth1.265 eth1.499 eth1.80 eth1.90 bridge-slave-eth1.80', shell=True)
        call('sudo nmcli con del bridge-slave-eth1 bridge-slave-eth2 bridge-slave-eth3', shell=True)
        call('sudo nmcli con del bridge0 bridge bridge.15 nm-bridge br88 br11 br12 br15 bridge-slave br15-slave br15-slave1 br15-slave2 br10 br10-slave', shell=True)
        if os.path.isfile('/tmp/nm_veth_configured'):
            for item in ["vlan","eth1.99","eth1.299","eth1.399","eth1.65","eth1.165","eth1.265","eth1.499","eth1.80","eth1.90"]:
                call('ip link delete %s' % item, shell=True)
        call("nmcli connection down testeth1", shell=True)


    if tag == 'wifi':
        print "---------------------------"
        print "removing all wifi residues"
        call('sudo nmcli device disconnect wlan0', shell=True)
        call('sudo rm -rf /etc/sysconfig/network-scripts/keys-*', shell=True)
        call('find /etc/sysconfig/network-scripts/ -type f | xargs grep -l "TYPE=Wireless" | xargs sudo rm -rf', shell=True)
        #call('sudo service NetworkManager restart', shell=True)

    if 'ifcfg-rh' in tag:
        print "---------------------------"
        print "enabling ifcfg-plugin"
        call("sudo sh -c \"echo '[main]\nplugins=ifcfg-rh' > /etc/NetworkManager/NetworkManager.conf\" ", shell=True)

    if 'waitforip' in tag:
        print "---------------------------"
        print "waiting till original IP regained"
        while True:
            sleep(5)
            cfg = pexpect.spawn('ifconfig')
            if cfg.expect(['inet 10', pexpect.EOF]) == 0:
                break

    if tag == 'restart':
        print "---------------------------"
        print "restarting NM service"
        call('sudo service NetworkManager restart', shell=True)
        sleep(5)

    if tag == 'remove_dns_none':
        if call('grep dns /etc/NetworkManager/NetworkManager.conf', shell=True) == 0:
            call("sudo sed -i 's/dns=none//' /etc/NetworkManager/NetworkManager.conf", shell=True)
        call('sudo service NetworkManager restart', shell=True)
        sleep(5)

    if tag == 'bridge_server_ingore_carrier_with_dhcp':
        print "---------------------------"
        print "removing server config files"
        call('sudo yum -y remove NetworkManager-config-server', shell=True)

    if tag == 'openvswitch_ignore_ovs_network_setup':
        print "---------------------------"
        print "removing all openvswitch bridge and ethernet connections"
        call('sudo ifdown eth1', shell=True)
        call('sudo ifdown ovsbridge0', shell=True)
        call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth1', shell=True)
        call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-ovsbridge0', shell=True)
        call('sudo nmcli con reload', shell=True)
        call('sudo nmcli con del eth1', shell=True) # to be sure

    if tag == 'openvswitch_ignore_ovs_vlan_network_setup':
        print "---------------------------"
        print "removing openvswitch bridge and inner bridge connections"
        call('sudo ifdown intbr0', shell=True)
        call('sudo ifdown ovsbridge0', shell=True)
        call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-intbr0', shell=True)
        call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-ovsbridge0', shell=True)

    if tag == 'openvswitch_ignore_ovs_bond_network_setup':
        print "---------------------------"
        print "removing openvswitch bridge and inner bond and slaves connection"
        call('sudo ifdown bond0', shell=True)
        call('sudo ifdown ovsbridge0', shell=True)
        call('sudo ifdown eth1', shell=True)
        call('sudo ifdown eth2', shell=True)
        call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-bond0', shell=True)
        call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-ovsbridge0', shell=True)
        call('sudo nmcli con del eth1 eth2', shell=True)
        # well we might not have to do this, but since these profiles have been openswitch'ed
        # this is to make sure
        call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth1', shell=True)
        call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth2', shell=True)
        call('sudo nmcli con reload', shell=True)

    if 'openvswitch' in tag:
        print "---------------------------"
        print "regenerating eth1 and eth2 profiles after openvswitch manipulation"
        call('service openvswitch stop', shell=True)
        sleep(2)
        call('modprobe -r openvswitch', shell=True)
        # restore these default profiles
        call('sudo nmcli con add type ethernet ifname eth1 con-name eth1 autoconnect no', shell=True)
        call('sudo nmcli con add type ethernet ifname eth2 con-name eth2 autoconnect no', shell=True)

    if tag == 'hostname_change':
        print "---------------------------"
        print "restoring original hostname"
        call('sudo nmcli gen host %s' % context.original_hostname, shell=True)

    if tag == 'device_connect' or tag == 'ipv6_describe' or tag == 'testcase_304241':
        print "---------------------------"
        print "beah-beaker-backend sanitization"
        call('sudo kill $(ps aux|grep -v grep| grep /usr/bin/beah-beaker-backend |awk \'{print $2}\')', shell=True)
        sleep(1)
        os.system('beah-beaker-backend &')
        sleep(20)

    if tag == 'nmcli_general_correct_profile_activated_after_restart':
        print "---------------------------"
        print "beah-beaker-backend sanitization"
        call('sudo nmcli connection delete aaa bbb', shell=True)

def after_all(context):
    pass
    #call('sudo kill $(ps aux|grep -v grep| grep /usr/bin/beah-beaker-backend |awk \'{print $2}\')', shell=True)
    #Popen('beah-beaker-backend -H $(hostname) &', shell=True)

