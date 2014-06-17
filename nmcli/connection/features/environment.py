# -*- coding: UTF-8 -*-

import os
from subprocess import call
from time import sleep, localtime, strftime


# the order of these steps is as follows
# 1. before scenario
# 2. before tag
# 3. after scenario
# 4. after tag

TIMER = 0.5

def before_scenario(context, scenario):
    try:
        context.log = file('/tmp/log_%s.log' % scenario.name,'w')
        context.log_start_time = strftime("%Y-%m-%d %H:%M:%S", localtime())

    except Exception as e:
        print("Error in before_scenario: %s" % e.message)


def before_tag(context, tag):
    """
    """
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


def after_step(context, step):
    """
    """
    #pass
    sleep(TIMER)


def after_scenario(context, scenario):
    """
    """
#    try:
    # Attach journalctl logs
    call("sudo journalctl -u NetworkManager --no-pager -o cat --since='%s' > /tmp/journal-nm.log" % context.log_start_time, shell=True)
    data = open("/tmp/journal-nm.log", 'r').read()

    if data:
        context.embed('text/plain', data)

    if hasattr(context, "embed"):
        context.embed('text/plain', open("/tmp/log_%s.log" % scenario.name, 'r').read())

#    except Exception as e:
#        print("Error in after_scenario: %s" % e.message)


def after_tag(context, tag):
    """
    """
    if tag == "con":
        print "---------------------------"
        print "deleting connie"
        call("nmcli connection delete id connie", shell=True)
        #call("sleep 2", shell=True)
        print "---------------------------"

    if tag == "BBB":
        print "---------------------------"
        print "deleting BBB"
        call("nmcli connection delete id BBB", shell=True)
        #call("sleep 2", shell=True)
        print "---------------------------"


    if tag == "eth":
        print "---------------------------"
        print "deleting connie"
        call("nmcli connection delete id ethie", shell=True)
        #os.system("sleep 1")
        print "---------------------------"

    if tag == "firewall":
        print "---------------------------"
        print "stoppping firewall"
        call("sudo service firewalld stop", shell=True)
        #call("sleep 4", shell=True)
        print "---------------------------"

    if tag == "eth0":
        print "---------------------------"
        print "upping eth0"
        call("nmcli connection up id eth0", shell=True)
        #sleep(2*TIMER)
        print "---------------------------"

    if tag == "time":
        print "---------------------------"
        print "time connection delete"
        call("nmcli connection delete id time", shell=True)
        print "---------------------------"

