# -*- coding: UTF-8 -*-

import os

from time import sleep, localtime, strftime

TIMER = 1

def before_scenario(context, scenario):
    try:
        context.log = file('/tmp/log_%s.log' % scenario.name,'w')

        context.log_start_time = strftime("%Y-%m-%d %H:%M:%S", localtime())

        os.system("ip link set dev eth1 up")
        os.system("ip link set dev eth2 up")

        sleep(3*TIMER)

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

        if os.system(" nmcli c sh a |grep eth0") != 0:
            os.system("nmcli connection up id eth0")
            sleep(4)

        if hasattr(context, "embed"):
            context.embed('text/plain', open("/tmp/log_%s.log" % scenario.name, 'r').read())
    
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

            #if os.system("nmcli connection | grep bond0.0 -q") == 0:
            print "** deleting slave profiles"
            os.system('nmcli connection delete id bond0.0 bond0.1 bond-slave-eth1')

            #if os.system("nmcli connection | grep bond-slave-eth1 -q") == 0:
    #        os.system('nmcli connection delete id bond-slave-eth1')

            #if os.system("nmcli connection | grep bond0.1 -q") == 0:
     #       print "** deleting second slave profile"
     #       os.system('nmcli connection delete id ')
            
            sleep(TIMER)

        if tag == "bond":

            #if os.system('nmcli connection | grep "bond0 " -q') == 0:
            print "** deleting bond profile"
            os.system('nmcli connection delete id bond0 bond')
            #if os.system('nmcli connection | grep "bond " -q') == 0:
            #print "** deleting bond profile"
            #os.system('nmcli connection delete id bond')
                
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
            print os.system('ls /proc/net/bonding')
 
    except Exception as e:
        print("Error in after_tag: %s" % e.message)
        