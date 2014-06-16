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
    if 'vpn' in tag:
<<<<<<< HEAD
        print "---------------------------"
        print "deleting vpn connections"
        Popen("nmcli connection delete vpn", shell=True).wait()
=======
        pass
        print "---------------------------"
        print "deleting vpn connections"
        #Popen("nmcli connection delete vpn", shell=True).wait()
>>>>>>> 0eedc42... sync with old repo
        print "---------------------------"

def after_all(context):
    pass
    #if os.system("nmcli -f NAME c sh |grep Wired") != 0:
    #    print "---------------------------"
