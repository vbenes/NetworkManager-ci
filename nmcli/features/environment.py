# -*- coding: UTF-8 -*-

import os
import pexpect
from subprocess import call, Popen
from time import sleep, localtime, strftime


TIMER = 0.5

# the order of these steps is as follows
# 1. before scenario
# 2. before tag
# 3. after scenario
# 4. after tag

def before_scenario(context, scenario):
    try:
        context.log = file('/tmp/log_%s.log' % scenario.name,'w')

        context.log_start_time = strftime("%Y-%m-%d %H:%M:%S", localtime())

        os.system("ip link set dev eth1 up")
        os.system("ip link set dev eth2 up")

    except Exception as e:
        print("Error in before_scenario: %s" % e.message)

def before_tag(context, tag):
    if tag == 'eth0':
        print "---------------------------"
        print "eth0 disconnect"
        Popen("nmcli connection down id eth0", shell=True).wait()
        sleep(TIMER)
        if os.system("nmcli -f NAME c sh -a |grep eth0") == 0:
            print "shutting down eth0 once more as it is not down"
            Popen("nmcli device disconnect eth0", shell=True).wait()
            sleep(TIMER)
        print "---------------------------"

    if tag == "firewall":
        print "---------------------------"
        print "starting firewall"
        call("sudo systemctl unmask firewalld", shell=True)
        call("sudo service firewalld restart", shell=True)
        call("sleep 4", shell=True)
        print "---------------------------"

    if tag == "eth0":
        print "---------------------------"
        print "eth0 and eth10 disconnect"
        os.system("nmcli device disconnect eth0")
        os.system("nmcli device disconnect eth10")
        sleep(TIMER)
        print "---------------------------"


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
            context.embed('text/plain', open("/tmp/log_%s.log" % scenario.name, 'r').read())

    except Exception as e:
        print("Error in after_scenario: %s" % e.message)

def after_tag(context, tag):
    """
    """
    if tag == 'ipv4':
        print "---------------------------"
        print "deleting connection ethie"
        call("nmcli connection delete id ethie", shell=True)
        print "---------------------------"

    if tag == 'ipv4_2':
        print "---------------------------"
        print "deleting connections ethie and ethie2"
        call("nmcli connection delete id ethie2", shell=True)
        call("nmcli connection delete id ethie", shell=True)
        print "---------------------------"

#    if tag == 'eth0':
#        print "---------------------------"
#        print "starting eth0"
#        call("nmcli connection up id eth0", shell=True)
#        call('sudo service beah-beaker-backend restart', shell=True)

    if tag == 'alias':
        print "---------------------------"
        print "deleting alias connections"
        call("nmcli connection delete eth7", shell=True)
        call("sudo rm -f /etc/sysconfig/network-scripts/ifcfg-eth7:0", shell=True)
        call("sudo rm -f /etc/sysconfig/network-scripts/ifcfg-eth7:1", shell=True)
        call("sudo rm -f /etc/sysconfig/network-scripts/ifcfg-eth7:2", shell=True)
        call("sudo nmcli connection reload", shell=True)
        print "---------------------------"

    if tag == "slaves":
        print "---------------------------"
        print "deleting slave profiles"
        call'nmcli connection delete id bond0.0 bond0.1 bond-slave-eth1', shell=True)
        print "---------------------------"

    if tag == "bond":
        print "---------------------------"
        print "deleting bond profile"
        call('nmcli connection delete id bond0 bond', shell=True)
        print os.system('ls /proc/net/bonding')
        print "---------------------------"

    if tag == "con":
        print "---------------------------"
        print "deleting connie"
        call("nmcli connection delete id connie", shell=True)
        print "---------------------------"

    if tag == "BBB":
        print "---------------------------"
        print "deleting BBB"
        call("nmcli connection delete id BBB", shell=True)
        print "---------------------------"

    if tag == "eth":
        print "---------------------------"
        print "deleting ethie"
        call("nmcli connection delete id ethie", shell=True)
        print "---------------------------"

    if tag == "firewall":
        print "---------------------------"
        print "stoppping firewall"
        call("sudo service firewalld stop", shell=True)
        print "---------------------------"

    if tag == "eth0":
        print "---------------------------"
        print "upping eth0"
        call("nmcli connection up id eth0", shell=True)
        print "---------------------------"

    if tag == "time":
        print "---------------------------"
        print "time connection delete"
        call("nmcli connection delete id time", shell=True)
        print "---------------------------"

    if tag == 'dcb':
        print "---------------------------"
        print "deleting connection dcb"
        call("nmcli connection down id dcb", shell=True)
        call("nmcli connection delete id dcb", shell=True)
        #sleep(10*TIMER)
        print "---------------------------"

    if tag == 'inf':
        print "---------------------------"
        print "deleting infiniband connections"
        call("nmcli device disconnect mlx4_ib1", shell=True)
        call("nmcli device disconnect mlx4_ib1.8003", shell=True)
        call("nmcli connection delete id inf", shell=True)
        call("nmcli connection delete id infiniband-mlx4_ib1", shell=True)
        call("nmcli connection delete id inf.8003", shell=True)
        call("nmcli connection delete id infiniband-mlx4_ib1.8003", shell=True)
        #sleep(10*TIMER)
        print "---------------------------"

    if tag == "profie":
        print "---------------------------"
        print "deleting profile profile"
        call("nmcli connection delete id profie", shell=True)
        print "---------------------------"

    if tag == "ipv6" or tag == "ipv6_2":
        print "---------------------------"
        print "deleting connections"
        if tag == "ipv6_2":
            call("nmcli connection delete id ethie2", shell=True)
        call("nmcli connection delete id ethie", shell=True)
        print "---------------------------"

    if tag == "team_slaves":
        call('nmcli connection delete id team0.0 team0.1 team-slave-eth2 team-slave-eth1', shell=True)

    if tag == "team":
        print "** deleting team profile"
        call('nmcli connection delete id team0 team', shell=True)


def after_all(context):
    Popen("nmcli connection up id eth0", shell=True).wait()
    os.system('sudo service beah-beaker-backend restart')
    sleep(5*TIMER)
    print "---------------------------"

