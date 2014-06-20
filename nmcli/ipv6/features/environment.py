# -*- coding: UTF-8 -*-

import os
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
        if os.system("nmcli -f NAME c sh |grep ethie") == 0:
            Popen("nmcli connection delete id ethie", shell=True).wait()
            sleep(2*TIMER)
    except Exception as e:
        print("Error in before_scenario: %s" % e.message)


def before_tag(context, tag):
    #try:
    if tag == 'eth0':
        print "---------------------------"
        print "eth0"# and eth10 disconnect"
        Popen("nmcli connection down id eth0", shell=True).wait()
        sleep(TIMER)
        if os.system("nmcli -f NAME c sh -a |grep eth0") == 0:
            print "shutting down eth0 once more as it is not down"
            Popen("nmcli device disconnect eth0", shell=True).wait()
            sleep(TIMER)
        print "---------------------------"

#    except Exception as e:
#        print("Error in before_tag: %s" % e.message)

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
    if tag == "profie":
        print "---------------------------"
        print "deleting profile profile"
        Popen("nmcli connection delete id profie", shell=True).wait()
        sleep(TIMER)
        print "---------------------------"

    if tag == "ipv6" or tag == "ipv6_2":
        print "---------------------------"
        print "deleting connections"
        if tag == "ipv6_2":
            Popen("nmcli connection delete id ethie2", shell=True).wait()
        Popen("nmcli connection delete id ethie", shell=True).wait()
        sleep(TIMER)
        print "---------------------------"

    if tag == 'eth0':
        print "---------------------------"
        print "starting eth0"
        Popen("nmcli connection up id eth0", shell=True).wait()
        os.system('sudo service beah-beaker-backend restart')
        sleep(TIMER)

def after_all(context):
    if os.system("nmcli -f NAME c sh -a |grep eth0") != 0:
        Popen("nmcli connection up id eth0", shell=True).wait()
        os.system('sudo service beah-beaker-backend restart')
        sleep(5*TIMER)
        print "---------------------------"


