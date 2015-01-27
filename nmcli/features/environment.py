# -*- coding: UTF-8 -*-

import os
import pexpect
from subprocess import call, check_output
from time import sleep, localtime, strftime


TIMER = 0.5

# the order of these steps is as follows
# 1. before scenario
# 2. before tag
# 3. after scenario
# 4. after tag

def dump_status(context, when):
    context.log.write("Network configuration %s:\n\n" % when)
    for cmd in ['ip addr', 'ip -4 route', 'ip -6 route',
        'nmcli g', 'nmcli c', 'nmcli d', 'nmcli -f IN-USE,SSID,CHAN,SIGNAL,SECURITY d w']:
             context.log.write("--- %s ---\n" % cmd)
             context.log.flush()
             call(cmd, shell=True, stdout=context.log)
             context.log.write("\n")

def before_scenario(context, scenario):
    try:

        if '1000' in scenario.tags:
            print "---------------------------"
            print "installing pip and pyroute2"
            if not os.path.isfile('/usr/bin/pip'):
                call('sudo easy_install pip', shell=True)
            call('pip install pyroute2', shell=True)

        if 'veth' in scenario.tags:
            if os.path.isfile('/tmp/nm_veth_configured'):
                import sys
                sys.exit(0)

        if 'eth0' in scenario.tags:
            print "---------------------------"
            print "eth0 disconnect"
            call("nmcli con down testeth0", shell=True)
            call('nmcli con down testeth1', shell=True)
            call('nmcli con down testeth2', shell=True)

        if 'alias' in scenario.tags:
            print "---------------------------"
            print "deleting eth7 connections"
            call("nmcli connection up testeth7", shell=True)
            call("nmcli connection delete eth7", shell=True)

        if 'scapy' in scenario.tags:
            print "---------------------------"
            print "installing scapy and tcpdump"
            if not os.path.isfile('/usr/bin/pip'):
                call('sudo easy_install pip', shell=True)
            if not os.path.isfile('/usr/bin/scapy'):
                call('sudo yum -y install tcpdump', shell=True)
                call("sudo pip install http://www.secdev.org/projects/scapy/files/scapy-latest.tar.gz", shell=True)

        if 'mock' in scenario.tags:
            print "---------------------------"
            print "installing dbus-x11, pip, and python-dbusmock"
            if call('rpm -q --quiet dbus-x11', shell=True) != 0:
                call('yum -y install dbus-x11', shell=True)
            if not os.path.isfile('/usr/bin/pip'):
                call('sudo easy_install pip', shell=True)
            if call('pip list |grep python-dbusmock', shell=True) != 0:
                call("sudo pip install python-dbusmock", shell=True)

        if 'IPy' in scenario.tags:
            print "---------------------------"
            print "installing dbus-x11, pip, and IPy"
            if call('rpm -q --quiet dbus-x11', shell=True) != 0:
                call('yum -y install dbus-x11', shell=True)
            if not os.path.isfile('/usr/bin/pip'):
                call('sudo easy_install pip', shell=True)
            if call('pip list |grep IPy', shell=True) != 0:
                call("sudo pip install IPy", shell=True)

        if 'dhcpd' in scenario.tags:
            print "---------------------------"
            print "installing dhcp"
            if call('rpm -q --quiet dhcp', shell=True) != 0:
                call('yum -y install dhcp', shell=True)

        if 'dummy' in scenario.tags:
            print "---------------------------"
            print "removing dummy devices"
            call("ip link add dummy0 type dummy", shell=True)
            call("ip link delete dummy0", shell=True)

        if 'delete_testeth0' in scenario.tags:
            print "---------------------------"
            print "delete testeth0"
            call("nmcli connection delete id testeth0", shell=True)

        if 'firewall' in scenario.tags:
            print "---------------------------"
            print "starting firewall"
            call("sudo yum -y install firewalld", shell=True)
            call("sudo systemctl unmask firewalld", shell=True)
            call("sudo systemctl start firewalld", shell=True)
            #call("sleep 4", shell=True)

        if 'tshark' in scenario.tags:
            print "---------------------------"
            print "ip link up eth10 connection"
            if os.path.isfile('/tmp/nm_veth_configured'):
                call("ip link set dev eth10 up", shell=True)
                call("ip link set dev eth0p up", shell=True)

        if ('ethernet' in scenario.tags) or ('bridge' in scenario.tags) or ('vlan' in scenario.tags):
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
            #call('sudo nmcli con down testeth1', shell=True)
            #call('sudo nmcli con down testeth2', shell=True)

        if 'logging' in scenario.tags:
            context.loggin_level = check_output('nmcli -t -f LEVEL general logging', shell=True).strip()

        if 'vlan' in scenario.tags or 'bridge' in scenario.tags:
            print "---------------------------"
            print "connecting eth1"
            if os.path.isfile('/tmp/nm_veth_configured'):
                call("ip link set dev eth1 up", shell=True)
                call("ip link set dev eth1p up", shell=True)
                sleep(1)
            call("nmcli connection up testeth1", shell=True)

        if 'bond' in scenario.tags or 'team' in scenario.tags:
            print "---------------------------"
            print "ip upping eth1/eth2"
            if os.path.isfile('/tmp/nm_veth_configured'):
                call("ip link set dev eth1 up", shell=True)
                call("ip link set dev eth2 up", shell=True)
                call('nmcli con up testeth1', shell=True)

        if 'restore_hostname' in scenario.tags:
            print "---------------------------"
            print "saving original hostname"
            context.original_hostname = check_output('cat /etc/hostname', shell=True).strip()

        if 'runonce' in scenario.tags:
            print "---------------------------"
            print "stop all networking services and prepare configuration"
            call("systemctl stop network", shell=True)
            call("nmcli device disconnect eth0", shell=True)
            call("pkill -9 dhclient", shell=True)
            call("pkill -9 nm-iface-helper", shell=True)

        if 'openvswitch' in scenario.tags:
            print "---------------------------"
            print "deleting eth1 and eth2 for openswitch tests"
            call('sudo nmcli con del eth1 eth2', shell=True) # delete these profile, we'll work with other ones

        if 'nmcli_general_ignore_specified_unamanaged_devices' in scenario.tags:
            print "---------------------------"
            print "backing up NetworkManager.conf"
            call('sudo cp -f /etc/NetworkManager/NetworkManager.conf /tmp/bckp_nm.conf', shell=True)

        if 'ipv6_keep_connectivity_on_assuming_connection_profile' in scenario.tags:
            print "---------------------------"
            print "removing testeth10 profile"
            call('sudo nmcli connection delete testeth10', shell=True)

        context.log = file('/tmp/log_%s.html' % scenario.name,'w')
        context.log_start_time = strftime("%Y-%m-%d %H:%M:%S", localtime())
        dump_status(context, 'before %s' % scenario.name)

    except Exception as e:
        print("Error in before_scenario: %s" % e.message)


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

        dump_status(context, 'after %s' % scenario.name)
        context.log.close ()
        context.embed('text/plain', open("/tmp/log_%s.html" % scenario.name, 'r').read())

        if '1000' in scenario.tags:
            print "---------------------------"
            print "deleting bridge0 and 1000 dummy devices"
            call("ip link del bridge0", shell=True)
            call("for i in $(seq 0 1000); do ip link del port$i ; done", shell=True)

        if 'ipv4' in scenario.tags:
            print "---------------------------"
            print "deleting connection ethie"
            call("nmcli connection delete id ethie", shell=True)
            #sleep(TIMER)

        if 'ipv4_2' in scenario.tags:
            print "---------------------------"
            print "deleting connections ethie and ethie2"
            call("nmcli connection delete id ethie2", shell=True)
            call("nmcli connection delete id ethie", shell=True)
            #sleep(TIMER)

        if 'alias' in scenario.tags:
            print "---------------------------"
            print "deleting alias connections"
            call("nmcli connection delete eth7", shell=True)
            call("sudo rm -f /etc/sysconfig/network-scripts/ifcfg-aliaseth7:0", shell=True)
            call("sudo rm -f /etc/sysconfig/network-scripts/ifcfg-aliaseth7:1", shell=True)
            call("sudo rm -f /etc/sysconfig/network-scripts/ifcfg-aliaseth7:2", shell=True)
            call("sudo nmcli connection reload", shell=True)
            #call('sudo nmcli con add type ethernet ifname eth7 con-name testeth7 autoconnect no', shell=True)
            #sleep(TIMER)

        if 'slaves' in scenario.tags:
            print "---------------------------"
            print "deleting slave profiles"
            call('nmcli connection delete id bond0.0 bond0.1 bond-slave-eth1', shell=True)
            #sleep(TIMER)

        if 'bond' in scenario.tags:
            print "---------------------------"
            print "deleting bond profile"
            call('nmcli connection delete id bond0 bond', shell=True)

            #sleep(TIMER)
            print os.system('ls /proc/net/bonding')

        if 'con' in scenario.tags:
            print "---------------------------"
            print "deleting connie"
            call("nmcli connection delete id connie", shell=True)
            #sleep(TIMER)

        if 'BBB' in scenario.tags:
            print "---------------------------"
            print "deleting BBB"
            call("ip link delete BBB", shell=True)
            call("nmcli connection delete id BBB", shell=True)
            #sleep(TIMER)

        if 'disp' in scenario.tags:
            print "---------------------------"
            print "deleting dispatcher files"
            call("rm -rf /etc/NetworkManager/dispatcher.d/*-disp", shell=True)
            call("rm -rf /etc/NetworkManager/dispatcher.d/pre-up.d/98-disp", shell=True)
            call("rm -rf /etc/NetworkManager/dispatcher.d/pre-down.d/97-disp", shell=True)
            call("rm -rf /tmp/dispatcher.txt", shell=True)

        if 'eth' in scenario.tags:
            print "---------------------------"
            print "deleting ethie"
            call("nmcli connection delete id ethie", shell=True)
            #sleep(TIMER)

        if 'firewall' in scenario.tags:
            print "---------------------------"
            print "stoppping firewall"
            call("sudo service firewalld stop", shell=True)
            #sleep(TIMER)

        if 'ipv6_describe' in scenario.tags or 'testcase_304241' in scenario.tags:
            call('sudo kill -9 $(ps aux|grep -v grep| grep /usr/bin/beah-beaker-backend |awk \'{print $2}\')', shell=True)
            sleep(1)
            os.system('beah-beaker-backend &')
            sleep(20)

        if 'logging' in scenario.tags:
            print "---------------------------"
            print "setting log level back"
            call('sudo nmcli g log level %s domains ALL' % context.loggin_level, shell=True)

        if 'eth0' in scenario.tags:
            print "---------------------------"
            print "upping eth0"
            if os.path.isfile('/tmp/nm_veth_configured'):
                call("ip link set dev eth0 up address $(cat /tmp/nm_orig_mac)", shell=True)
                call("ip link set dev eth0p up", shell=True)

            call("nmcli connection up id testeth0", shell=True)
            sleep(2)

        if 'time' in scenario.tags:
            print "---------------------------"
            print "time connection delete"
            call("nmcli connection delete id time", shell=True)
            #sleep(TIMER)

        if 'dcb' in scenario.tags:
            print "---------------------------"
            print "deleting connection dcb"
            call("nmcli connection down id dcb", shell=True)
            call("nmcli connection delete id dcb", shell=True)
            sleep(10*TIMER)

        if 'two_bridged_veths' in scenario.tags:
            print "---------------------------"
            print "deleting veth devices"
            call("nmcli connection delete id tc1 tc2", shell=True)
            call("ip link del test1", shell=True)
            call("ip link del test2", shell=True)
            call("ip link del vethbr", shell=True)
            call("nmcli con del tc1 tc2 vethbr", shell=True)

        if 'dhcpd' in scenario.tags:
            print "---------------------------"
            print "deleting veth devices"
            call("sudo service dhcpd stop", shell=True)

        if 'mtu' in scenario.tags:
            print "---------------------------"
            print "deleting veth devices from mtu test"
            call("nmcli connection delete id tc1 tc2", shell=True)
            call("ip link delete test1", shell=True)
            call("ip link delete test2", shell=True)
            call("ip link delete test1", shell=True)
            call("ip link delete test2", shell=True)
            call("ip link set dev vethbr down", shell=True)
            call("brctl delbr vethbr", shell=True)
            call("kill -9 $(ps aux|grep '/usr/sbin/dns' |grep 192.168 |grep -v grep |awk '{print $2}')", shell=True)
            call("kill -9 $(ps aux|grep '/usr/sbin/dns' |grep 192.168 |grep -v grep |awk '{print $2}')", shell=True)

        if 'inf' in scenario.tags:
            print "---------------------------"
            print "deleting infiniband connections"
            call("nmcli device disconnect mlx4_ib1", shell=True)
            call("nmcli device disconnect mlx4_ib1.8003", shell=True)
            call("nmcli connection delete id inf", shell=True)
            call("nmcli connection delete id infiniband-mlx4_ib1", shell=True)
            call("nmcli connection delete id inf.8003", shell=True)
            call("nmcli connection delete id infiniband-mlx4_ib1.8003", shell=True)
            call("nmcli connection up id tg3_1", shell=True)
            sleep(10*TIMER)

        if 'profie' in scenario.tags:
            print "---------------------------"
            print "deleting profile profile"
            call("nmcli connection delete id profie", shell=True)
            #sleep(TIMER)

        if 'peers_ns' in scenario.tags:
            print "---------------------------"
            print "deleting peers namespace"
            call("ip netns del peers", shell=True)
            #sleep(TIMER)

        if 'runonce' in scenario.tags:
            print "---------------------------"
            print "delete profiles and start NM"
            call("pkill -9 nm-iface-helper", shell=True)
            call("rm -rf /etc/NetworkManager/conf.d/00-run-once.conf", shell=True)
            call("systemctl restart  NetworkManager", shell=True)
            call("nmcli connection delete ethie", shell=True)
            call("nmcli connection up testeth0", shell=True)


        if 'ipv6' in scenario.tags or 'ipv6_2' in scenario.tags:
            print "---------------------------"
            print "deleting connections"
            if 'ipv6_2' in scenario.tags:
                call("nmcli connection delete id ethie2", shell=True)
            call("nmcli connection delete id ethie", shell=True)
            #sleep(TIMER)

        if 'team_slaves' in scenario.tags:
            print "---------------------------"
            print "deleting team slaves"
            call('nmcli connection delete id team0.0 team0.1 team-slave-eth2 team-slave-eth1', shell=True)
            #sleep(TIMER)

        if 'team' in scenario.tags:
            print "---------------------------"
            print "deleting team masters"
            call('nmcli connection delete id team0 team', shell=True)
            #sleep(TIMER)

        if 'ethernet' in scenario.tags:
            print "---------------------------"
            print "removing ethernet profiles"
            call("sudo nmcli connection delete id ethernet ethos", shell=True)
            call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-ethernet*', shell=True) #ideally should do nothing

        if ('vlan' in scenario.tags) or ('bridge' in scenario.tags):
            print "---------------------------"
            print "deleting all possible bridge residues"
            call('sudo nmcli con del vlan eth1.99 eth1.299 eth1.399 eth1.65 eth1.165 eth1.265 eth1.499 eth1.80 eth1.90 bridge-slave-eth1.80', shell=True)
            call('sudo nmcli con del bridge-slave-eth1 bridge-slave-eth2 bridge-slave-eth3', shell=True)
            call('sudo nmcli con del bridge0 bridge bridge.15 nm-bridge br88 br11 br12 br15 bridge-slave br15-slave br15-slave1 br15-slave2 br10 br10-slave', shell=True)
            if os.path.isfile('/tmp/nm_veth_configured'):
                for item in ["vlan","eth1.99","eth1.299","eth1.399","eth1.65","eth1.165","eth1.265","eth1.499","eth1.80","eth1.90"]:
                    call('ip link delete %s' % item, shell=True)
            call("nmcli connection down testeth1", shell=True)

        if 'vpn' in scenario.tags:
            print "---------------------------"
            print "removing vpn profiles"
            call("nmcli connection delete vpn", shell=True)

        if 'scapy' in scenario.tags:
            print "---------------------------"
            print "removing veth devices"
            call("ip link delete test10", shell=True)
            call("ip link delete test11", shell=True)
            call("nmcli connection delete ethernet-test10 ethernet-test11", shell=True)

        if 'dummy' in scenario.tags:
            print "---------------------------"
            print "removing dummy and bridge/bond/team devices"
            call("ip link delete dummy0", shell=True)
            call("ip link del br0", shell=True)
            call("ip link del bond0", shell=True)
            call("ip link del team0", shell=True)


        if 'wifi' in scenario.tags:
            print "---------------------------"
            print "removing all wifi residues"
            #call('sudo nmcli device disconnect wlan0', shell=True)
            call('sudo nmcli con del qe-open qe-wep qe-wep-psk qe-wep-enterprise qe-wep-enterprise-cisco', shell=True)
            call('sudo nmcli con del qe-wpa1-psk qe-wpa2-psk qe-wpa1-enterprise qe-wpa2-enterprise qe-hidden-wpa2-psk', shell=True)
            call('sudo nmcli con del qe-adhoc wifi-wlan0', shell=True)
            if 'testcase_309441' in scenario.tags:
                context.prompt.close()
                sleep(1)
                call('sudo nmcli con del wifi-wlan0', shell=True)
            #call('sudo nmcli device disconnect wlan0', shell=True)
            #call('sudo rm -rf /etc/sysconfig/network-scripts/keys-*', shell=True)
            #call('find /etc/sysconfig/network-scripts/ -type f | xargs grep -l "TYPE=Wireless" | xargs sudo rm -rf', shell=True)
            #call('sudo service NetworkManager restart', shell=True)

        if 'ifcfg-rh' in scenario.tags:
            print "---------------------------"
            print "enabling ifcfg-plugin"
            call("sudo sh -c \"echo '[main]\nplugins=ifcfg-rh' > /etc/NetworkManager/NetworkManager.conf\" ", shell=True)

        if 'waitforip' in scenario.tags:
            print "---------------------------"
            print "waiting till original IP regained"
            while True:
                sleep(5)
                cfg = pexpect.spawn('ifconfig')
                if cfg.expect(['inet 10', pexpect.EOF]) == 0:
                    break

        if 'restart' in scenario.tags:
            print "---------------------------"
            print "restarting NM service"
            call('sudo service NetworkManager restart', shell=True)
            if os.path.isfile('/tmp/nm_veth_configured'):
                call('ip link set dev isobr up')
                call('ip link set dev outbr up')
            sleep(5)

        if 'remove_dns_none' in scenario.tags:
            if call('grep dns /etc/NetworkManager/NetworkManager.conf', shell=True) == 0:
                call("sudo sed -i 's/dns=none//' /etc/NetworkManager/NetworkManager.conf", shell=True)
            call('sudo service NetworkManager restart', shell=True)
            sleep(5)

        if 'bridge_server_ingore_carrier_with_dhcp' in scenario.tags:
            print "---------------------------"
            print "removing server config files"
            call('sudo yum -y remove NetworkManager-config-server', shell=True)

        if 'openvswitch_ignore_ovs_network_setup' in scenario.tags:
            print "---------------------------"
            print "removing all openvswitch bridge and ethernet connections"
            call('sudo ifdown eth1', shell=True)
            call('sudo ifdown ovsbridge0', shell=True)
            call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth1', shell=True)
            call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-ovsbridge0', shell=True)
            call('sudo nmcli con reload', shell=True)
            call('sudo nmcli con del eth1', shell=True) # to be sure

        if 'openvswitch_ignore_ovs_vlan_network_setup' in scenario.tags:
            print "---------------------------"
            print "removing openvswitch bridge and inner bridge connections"
            call('sudo ifdown intbr0', shell=True)
            call('sudo ifdown ovsbridge0', shell=True)
            call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-intbr0', shell=True)
            call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-ovsbridge0', shell=True)

        if 'openvswitch_ignore_ovs_bond_network_setup' in scenario.tags:
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

        if 'openvswitch' in scenario.tags:
            print "---------------------------"
            print "regenerating eth1 and eth2 profiles after openvswitch manipulation"
            call('service openvswitch stop', shell=True)
            sleep(2)
            call('modprobe -r openvswitch', shell=True)
            # restore these default profiles
            call('sudo nmcli con add type ethernet ifname eth1 con-name eth1 autoconnect no', shell=True)
            call('sudo nmcli con add type ethernet ifname eth2 con-name eth2 autoconnect no', shell=True)

        if 'restore_hostname' in scenario.tags:
            print "---------------------------"
            print "restoring original hostname"
            call('sudo nmcli gen host %s' % context.original_hostname, shell=True)

        if 'ipv6_describe' in scenario.tags or 'testcase_304241' in scenario.tags:
            print "---------------------------"
            print "beah-beaker-backend sanitization"
            call('sudo kill $(ps aux|grep -v grep| grep /usr/bin/beah-beaker-backend |awk \'{print $2}\')', shell=True)
            sleep(1)
            os.system('beah-beaker-backend &')
            sleep(20)

        if 'nmcli_general_correct_profile_activated_after_restart' in scenario.tags:
            print "---------------------------"
            print "deleting profiles"
            call('sudo nmcli connection delete aaa bbb', shell=True)

        if 'device_connect_no_profile' in scenario.tags or 'device_connect' in scenario.tags:
            print "---------------------------"
            print "env sanitization"
            call('nmcli connection delete testeth2 eth2', shell=True)
            call('nmcli connection add type ethernet ifname eth2 con-name testeth2 autoconnect no', shell=True)

        if 'nmcli_general_ignore_specified_unamanaged_devices' in scenario.tags:
            print "---------------------------"
            print "restoring original NetworkManager.conf and deleting bond device"
            call('sudo cp -f /tmp/bckp_nm.conf /etc/NetworkManager/NetworkManager.conf', shell=True)
            call('sudo ip link del dnt', shell=True)
            call('sudo ip link del bond0', shell=True)

        if 'nmcli_general_keep_slave_device_unmanaged' in scenario.tags:
            print "---------------------------"
            print "restoring the testeth1 profile to managed state / removing slave"
            call('sudo ip link del eth1.100', shell=True)
            call('sudo rm -f /etc/sysconfig/network-scripts/ifcfg-testeth1', shell=True)
            call('sudo nmcli connection reload', shell=True)
            call('nmcli connection add type ethernet ifname eth1 con-name testeth1 autoconnect no', shell=True)

        if 'nmcli_general_multiword_autocompletion' in scenario.tags:
            print "---------------------------"
            print "deleting profile in case of test failure"
            call('nmcli connection delete "Bondy connection 1"', shell=True)

        if 'add_testeth10' in scenario.tags:
            print "---------------------------"
            print "restoring testeth10 profile"
            call('sudo nmcli connection add type ethernet con-name testeth10 ifname eth10 autoconnect no', shell=True)
            call('sudo nmcli connection delete eth10', shell=True)

        if 'eth1_disconnect' in scenario.tags:
            print "---------------------------"
            print "disconnecting eth1 device"
            call('sudo nmcli device disconnect eth1', shell=True)

        if 'delete_testeth0' in scenario.tags:
            print "---------------------------"
            print "restoring testeth0 profile"
            call("nmcli connection add type ethernet con-name testeth0 ifname eth0", shell=True)
            call('sudo nmcli connection delete eth0', shell=True)

    except Exception as e:
        print("Error in after_scenario: %s" % e.message)



def after_all(context):
    pass
    #call('sudo kill $(ps aux|grep -v grep| grep /usr/bin/beah-beaker-backend |awk \'{print $2}\')', shell=True)
    #Popen('beah-beaker-backend -H $(hostname) &', shell=True)

