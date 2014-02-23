# -*- coding: UTF-8 -*-

import os

from time import sleep

def before_scenario(context, scenario):
    try:
        context.log = file('/tmp/log_%s.log' % scenario.name,'w')
        #os.system("for dev in $(nmcli device status |grep -v eth0 |grep -e ' connected' |awk {'print $1'}); do sudo nmcli device disconnect $dev; done")
        #if os.system("nmcli device status |grep -v eth0 |grep -v lo|grep -e ' connected'") != 1:
        #    os.system("for dev in $(nmcli device status |grep -v eth0 |grep -v lo|grep -e ' connected' |awk {'print $1'}); do sudo nmcli device disconnect $dev; done")
        os.system("nmcli connection delete id ethie")

        context.log_start_time = strftime("%Y-%m-%d %H:%M:%S", localtime())

    except Exception as e:
        print("Error in before_scenario: %s" % e.message)

def after_scenario(context, scenario):
    """
    """
    try:
        # Attach journalctl logs
        os.system("sudo journalctl -u NetworkManager --no-pager -o cat --since='%s' > /tmp/journal-nm.log" % context.log_start_time)
        data = open("/tmp/journal-nm.log", 'r').read()
        if data:
            context.embed('text/plain', data)

        if os.system(" nmcli c sh -a |grep eth0") != 0:
            print "---------------------------"
            print "starting eth0 as it was down"
            os.system("nmcli connection up id eth0")
            sleep(4)
            print "---------------------------"

        if hasattr(context, "embed"):
            context.embed('text/plain', open("/tmp/log_%s.log" % scenario.name, 'r').read())

    except Exception as e:
        print("Error in after_scenario: %s" % e.message)


def before_tag(context, tag):
    """
    """
    if tag == "firewall":
        print "---------------------------"
        print "starting firewall"
        os.system("sudo systemctl unmask firewalld")
        os.system("sudo service firewalld start")
        os.system("sleep 2")
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
    sleep(0.5)


def after_tag(context, tag):
    """
    """
    if tag == "eth":
        print "---------------------------"
        print "deleting cronnie"
        os.system("nmcli connection delete id connie")
#        os.system("sudo service NetworkManager restart")
        os.system("sleep 1")
        print "---------------------------"

    if tag == "firewall":
        print "---------------------------"
        print "stoppping firewall"
        #os.system("nmcli connection up id eth0")
        os.system("sudo service firewalld stop")
        os.system("sleep 1")
        print "---------------------------"

    if tag == "eth0":
        print "---------------------------"
        print "upping eth0"
        os.system("nmcli connection up id eth0")
        sleep(2*TIMER)
        print "---------------------------"

    if tag == "time":
        print "---------------------------"
        print "time connection delete"
        os.system("nmcli connection delete id time")
        print "---------------------------"

