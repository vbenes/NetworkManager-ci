# -*- coding: UTF-8 -*-

import os

from time import sleep, localtime, strftime

TIMER = 1

def before_scenario(context, scenario):
    try:
        context.log = file('/tmp/log_%s.log' % scenario.name,'w')

        os.system("ip link set dev eth1 up")
        os.system("ip link set dev eth2 up")

        context.log_start_time = strftime("%Y-%m-%d %H:%M:%S", localtime())

    except Exception as e:
        print("Error in before_scenario: %s" % e.message)

def after_scenario(context, scenario):
    """
    """
    try:
        # Attach journalctl logs
        if os.system("nmcli c sh -a |grep eth0") != 0:
            os.system("nmcli connection up id eth0")
            sleep(4)

        if hasattr(context, "embed"):
            context.embed('text/plain', open("/tmp/log_%s.log" % scenario.name, 'r').read())

            os.system("sudo journalctl -u NetworkManager --no-pager -o cat --since='%s' > /tmp/journal-nm.log" % context.log_start_time)
            data = open("/tmp/journal-nm.log", 'r').read()
            if data:
                context.embed('text/plain', data)

    except Exception as e:
        print("Error in after_scenario: %s" % e.message)

def after_step(context, step):
    """
    """
    sleep(0.5)

def after_tag(context, tag):
    """
    """
    try:
        if tag == "slaves":
            #if os.system('nmcli connection show active |grep p1p1') == 0:
            #print "** deactivating first slave"
            #os.system('nmcli device disconnect eth1')
            #sleep(TIMER)

            #if os.system('nmcli connection show active |grep p2p1') == 0:
            #print "** deactivating second slave"
            #os.system('nmcli device disconnect eth2')
            #sleep(TIMER)

            #if os.system("nmcli c|grep team0.0 -q") == 0:
            os.system('nmcli connection delete id team0.0 team0.1 team-slave-eth2 team-slave-eth1')
            #if os.system("nmcli c|grep team0.1 -q") == 0:
            #os.system('nmcli connection delete id team0.1')
            #if os.system("nmcli c|grep team-slave-eth1 -q") == 0:
            #os.system('nmcli connection delete id team-slave-eth1')
            #if os.system("nmcli c|grep team-slave-eth2 -q") == 0:
            #os.system('nmcli connection delete id ')
            sleep(TIMER)

        if tag == "team":

            print "** deleting team profile"
            #if os.system("nmcli c|grep team0 -q") == 0:
            os.system('nmcli connection delete id team0 team')
            #if os.system('nmcli c|grep "team " -q') == 0:
            #os.system('nmcli connection delete id team')
            sleep(TIMER)


            #print "** restart NM"
            #os.system("sudo service NetworkManager restart")
            #sleep(TIMER)

            #print "** removing kernel module"
            #os.system('sudo modprobe -r bonding')
            #sleep(TIMER)

            #print "** inserting it again with max_bonds=0"
            #os.system('sudo modprobe bonding max_bonds=0')
            #sleep(TIMER)

            #print "** restart NM"
            #os.system("sudo service NetworkManager restart")
            #sleep(TIMER)

    #        if os.system("nmcli connection | grep 'bond0 '"):
    #            print "** WARNING: Something went wrong, repeating deletion"
    #
    #            print "** deactivating bond"
    #            os.system('nmcli device disconnect nm-bond')
    #            sleep(TIMER)
    #
    #            print "** deleting bond profile"
    #            os.system('nmcli connection delete id bond0')
    #            sleep(TIMER)
    #
    #            print "** removing kernel module"
    #            os.system('sudo modprobe -r bonding')
    #            sleep(TIMER)
    #
    #            print "** inserting it again with max_bonds=0"
    #            os.system('sudo modprobe bonding')
    #            sleep(TIMER)
    #
    #            print "** restart NM"
    #            os.system("sudo service NetworkManager restart")
    #            sleep(2*TIMER)
    #

    except Exception as e:
        print("Error in after_tag: %s" % e.message)
