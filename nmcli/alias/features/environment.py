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

    except Exception as e:
        print("Error in before_scenario: %s" % e.message)


def after_scenario(context, scenario):
    """
    """
    call("sudo journalctl -u NetworkManager --no-pager -o cat --since='%s' > /tmp/journal-nm.log" % context.log_start_time, shell=True)
    data = open("/tmp/journal-nm.log", 'r').read()

    if data:
        context.embed('text/plain', data)

    if hasattr(context, "embed"):
        context.embed('text/plain', open("/tmp/log_%s.log" % scenario.name, 'r').read())

def after_step(context, step):
    pass
    #sleep(0.5)

def after_tag(context, tag):
    """
    """
    if tag == 'alias':
        print "---------------------------"
        print "deleting alias connections"
        Popen("nmcli connection delete eth7", shell=True).wait()
        Popen("sudo rm -f /etc/sysconfig/network-scripts/ifcfg-eth7:0", shell=True).wait()
        Popen("sudo rm -f /etc/sysconfig/network-scripts/ifcfg-eth7:1", shell=True).wait()
        Popen("sudo rm -f /etc/sysconfig/network-scripts/ifcfg-eth7:2", shell=True).wait()
        Popen("sudo nmcli connection reload", shell=True).wait()
        sleep(2*TIMER)
        print "---------------------------"

def after_all(context):
    if os.system("nmcli -f NAME c sh |grep Wired") != 0:
        print "removing wired connection, adding eth7 back"
        Popen("nmcli connection delete id 'Wired connection 1'", shell=True).wait()
        Popen("nmcli connection add type ethernet con-name eth7 ifname eth7 autoconnect no", shell=True).wait()
        print "---------------------------"
