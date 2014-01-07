# -*- coding: UTF-8 -*-

import os

from time import sleep

def before_scenario(context, scenario):

    context.log = file('/tmp/log_%s.log' % scenario.name,'w')
    #os.system("for dev in $(nmcli device status |grep -v eth0 |grep -e ' connected' |awk {'print $1'}); do nmcli device disconnect $dev; done")
    #if os.system("nmcli device status |grep -v eth0 |grep -v lo|grep -e ' connected'") != 1:
    #    os.system("for dev in $(nmcli device status |grep -v eth0 |grep -v lo|grep -e ' connected' |awk {'print $1'}); do nmcli device disconnect $dev; done")

def after_scenario(context, scenario):
    """
    """
    if os.system(" nmcli c sh a |grep eth0") != 0:
        os.system("nmcli connection up id eth0")
        sleep(4)

    if hasattr(context, "embed"):
        context.embed('text/plain', open("/tmp/log_%s.log" % scenario.name, 'r').read())

def before_tag(context, tag):
    """
    """
    if tag == "firewall":
        #os.system("nmcli device disconnect eth0")
        os.system("sudo systemctl unmask firewalld")
        os.system("sudo service firewalld start")
        os.system("sleep 2")

    if tag == "eth0":
        os.system("nmcli device disconnect eth0")
        sleep(TIMER)

def after_step(context, step):
    """
    """
    sleep(0.5)


def after_tag(context, tag):
    """
    """
    if tag == "eth":
        os.system("nmcli connection delete id connie")
#        os.system("sudo service NetworkManager restart")
        os.system("sleep 1")

    if tag == "firewall":
        #os.system("nmcli connection up id eth0")
        os.system("sudo service firewalld stop")
        os.system("sleep 1")

    if tag == "eth0":
        os.system("nmcli connection up id eth0")
        sleep(2*TIMER)

    if tag == "time":
        os.system("nmcli connection delete id time")

