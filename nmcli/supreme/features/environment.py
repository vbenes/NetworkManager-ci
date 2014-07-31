# -*- coding: UTF-8 -*-

import os

from time import sleep
from subprocess import check_output, call

def before_all(context):
    """Setup evolution stuff
    Being executed before all features
    """
    pass

def before_tag(context, tag):
    """Setup for scenarios marked with tag
    If tag contains 'goa', then setup a goa account:
    google_goa will setup Google account etc.
    """
    #call('sudo service NetworkManager start', shell=True)
    if (tag == 'ethernet') or (tag == 'bridge') or (tag == 'vlan'):
        call("for dev in $(nmcli device status |grep -v eth0 |grep -e ' connected' |awk {'print $1'}); do sudo nmcli device disconnect $dev; done", shell=True)
        if call("nmcli device status |grep -v eth0 |grep -e ' connected'", shell=True) != 1:
            call("for dev in $(nmcli device status |grep -v eth0 |grep -e ' connected' |awk {'print $1'}); do sudo nmcli device disconnect $dev; done", shell=True)
        call('sudo nmcli con del eth1 eth2', shell=True)
        call('sudo nmcli con add type ethernet ifname eth1 con-name eth1 autoconnect no', shell=True)
        call('sudo ifup eth1', shell=True)
        call('sudo nmcli con add type ethernet ifname eth2 con-name eth2 autoconnect no', shell=True)
        call('sudo ifup eth2', shell=True)
        call('sudo nmcli con down eth1', shell=True)
        call('sudo nmcli con down eth2', shell=True)
    if tag == 'bridge':
        call("nmcli device connect eth1", shell=True)
    if tag == 'hostname_change':
        context.original_hostname = check_output('cat /etc/hostname', shell=True).strip()
    if 'openvswitch' in tag:
        call('sudo nmcli con del eth1 eth2', shell=True) # delete these profile, we'll work with other ones
    # try:
    #     if 'goa' in tag:
    #         context.execute_steps(
    #             u"* Add %s account via GOA" % tag.split('_')[1].capitalize())
    # except Exception as e:
    #     print("error in before_tag(%s): %s" % (tag, e.message))
    #     raise RuntimeError

def after_tag(context, tag):
    try:
        if tag == 'ethernet':
            call("sudo nmcli connection delete id ethernet ethos", shell=True)
            call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-ethernet*', shell=True) #ideally should do nothing
        if (tag == 'vlan') or (tag == 'bridge'):
            call('sudo nmcli con del vlan eth1.99 eth1.299 eth1.399 eth1.65 eth1.165 eth1.265 eth1.499 eth1.80 eth1.90 bridge-slave-eth1.80', shell=True)
            call('sudo nmcli con del bridge-slave-eth1 bridge-slave-eth2 bridge-slave-eth3', shell=True)
            call('sudo nmcli con del bridge0 bridge bridge.15 nm-bridge br88 br11 br12 br15 bridge-slave br15-slave br15-slave1 br15-slave2 br10 br10-slave', shell=True)
        if tag == 'wifi':
            call('sudo nmcli device disconnect wlan0', shell=True)
            call('sudo rm -rf /etc/sysconfig/network-scripts/keys-*', shell=True)
            call('find /etc/sysconfig/network-scripts/ -type f | xargs grep -l "TYPE=Wireless" | xargs sudo rm -rf', shell=True)
            #call('sudo service NetworkManager restart', shell=True)
        if 'ifcfg-rh' in tag:
            call("sudo sh -c \"echo '[main]\nplugins=ifcfg-rh' > /etc/NetworkManager/NetworkManager.conf\" ", shell=True)
        if 'waitforip' in tag:
            import pexpect
            while True:
                sleep(5)
                cfg = pexpect.spawn('ifconfig')
                if cfg.expect(['inet 10', pexpect.EOF]) == 0:
                    break
        if tag == 'restart':
            call('sudo service NetworkManager restart', shell=True)
            sleep(5)
        if tag == 'bridge_server_ingore_carrier_with_dhcp':
            call('sudo yum -y remove NetworkManager-config-server', shell=True)
        if tag == 'openvswitch_ignore_ovs_network_setup':
            call('sudo ifdown eth1', shell=True)
            call('sudo ifdown ovsbridge0', shell=True)
            call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth1', shell=True)
            call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-ovsbridge0', shell=True)
            call('sudo nmcli con reload', shell=True)
            call('sudo nmcli con del eth1', shell=True) # to be sure
        if tag == 'openvswitch_ignore_ovs_vlan_network_setup':
            call('sudo ifdown intbr0', shell=True)
            call('sudo ifdown ovsbridge0', shell=True)
            call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-intbr0', shell=True)
            call('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-ovsbridge0', shell=True)
        if tag == 'openvswitch_ignore_ovs_bond_network_setup':
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
        if 'openvswitch' in tag:
            call('service openvswitch stop', shell=True)
            sleep(2)
            call('modprobe -r openvswitch', shell=True)
            # restore these default profiles
            call('sudo nmcli con add type ethernet ifname eth1 con-name eth1 autoconnect no', shell=True)
            call('sudo nmcli con add type ethernet ifname eth2 con-name eth2 autoconnect no', shell=True)
        if tag == 'hostname_change':
            call('sudo nmcli gen host %s' % context.original_hostname, shell=True)
        if tag == 'device_connect':# or tag == 'testcase_290429':# or tag == 'testcase_290426':
            #pass
            #call('sudo service NetworkManager restart', shell=True)
            sleep(10)
            call('sudo kill $(ps aux|grep -v grep| grep /usr/bin/beah-beaker-backend |awk \'{print $2}\')', shell=True)
            #sleep(1)
            os.system('beah-beaker-backend &')
            sleep(20)
            #Popen('beah-beaker-backend -H $(hostname) &', shell=True, close_fds=True)

    except Exception as e:
        print("error in after_tag(%s): %s" % (tag, e.message))
        raise RuntimeError
    #time for NM to update based on deleted configs
    sleep(0.5)

def after_step(context, step):
    """Teardown after each step.
    Here we make screenshot and embed it (if one of formatters supports it)
    """
    pass
    #sleep(0.2)
    # try:
    #     # Make screnshot if step has failed
    #     if hasattr(context, "embed"):
    #         os.system("gnome-screenshot -f /tmp/screenshot.jpg")
    #         context.embed('image/jpg', open("/tmp/screenshot.jpg", 'r').read())

    #     if step.status == 'failed' and os.environ.get('DEBUG_ON_FAILURE'):
    #         import ipdb; ipdb.set_trace()

    # except Exception as e:
    #     #print("Error in after_step: %s" % e)
    #     pass

def before_scenario(context, scenario):
    context.log = file('/tmp/log_%s.log' % scenario.name,'w')

def after_scenario(context, scenario):
    """Teardown for each scenario
    """
    print('============ /tmp/log_%s.log: ============' % scenario.name)
    print(open("/tmp/log_%s.log" % scenario.name, 'r').read())
    # try:
    #     # Stop evolution
    #     os.system("killall -9 evolution &> /dev/null")

    #     # Attach logs
    #     if hasattr(context, "embed"):
    #         context.embed('text/plain', open("/tmp/evo.log", 'r').read())
    #         os.system("rm -rf evo.log")

    #     # Make some pause after scenario
    #     sleep(10)
    # except Exception as e:
    #     # Stupid behave simply crashes in case exception has occurred
    #     pass


def after_all(context):
    pass