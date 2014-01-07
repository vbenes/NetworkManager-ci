# -*- coding: UTF-8 -*-

import os

from time import sleep

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
    if ('ethernet' in tag) or ('bridge' in tag):
        os.system("for dev in $(nmcli device status |grep -v eth0 |grep -e ' connected' |awk {'print $1'}); do sudo nmcli device disconnect $dev; done")
        if os.system("nmcli device status |grep -v eth0 |grep -e ' connected'") != 1:
            os.system("for dev in $(nmcli device status |grep -v eth0 |grep -e ' connected' |awk {'print $1'}); do sudo nmcli device disconnect $dev; done")
    if 'bridge' in tag:
        os.system("nmcli connection up eth1")

    # try:
    #     if 'goa' in tag:
    #         context.execute_steps(
    #             u"* Add %s account via GOA" % tag.split('_')[1].capitalize())
    # except Exception as e:
    #     print("error in before_tag(%s): %s" % (tag, e.message))
    #     raise RuntimeError

def after_tag(context, tag):
    #try:
    if 'ethernet' in tag:
        os.system("sudo nmcli connection delete id ethernet")
        os.system('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-ethernet*') #ideally should do nothing
    if ('vlan' in tag) or ('bridge' in tag):
        os.system('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth0.* /etc/sysconfig/network-scripts/ifcfg-vlan*')
        os.system('sudo modprobe -r  8021q ; sudo modprobe 8021q')
        os.system('sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-br* /etc/sysconfig/network-scripts/ifcfg-nm-bridge*')
        os.system('sudo modprobe -r bridge ; sudo modprobe bridge')
        os.system('sudo service NetworkManager restart')
    if 'wifi' in tag:
        os.system('sudo nmcli device disconnect wlan0')
        os.system('sudo rm -rf /etc/sysconfig/network-scripts/keys-*')
        os.system('find /etc/sysconfig/network-scripts/ -type f | xargs grep -l "TYPE=Wireless" | xargs sudo rm -rf')
        os.system('sudo service NetworkManager restart')
    if 'ifcfg-rh' in tag:
        os.system("sudo sh -c \"echo '[main]\nplugins=ifcfg-rh' > /etc/NetworkManager/NetworkManager.conf\" ")
    if 'waitforip' in tag:
        import pexpect
        while True:
            sleep(5)
            cfg = pexpect.spawn('ifconfig')
            if cfg.expect(['inet 10', pexpect.EOF]) == 0:
                break
    if 'restart' in tag:
        os.system('sudo service NetworkManager restart')
    #except Exception as e:
    #    print("error in after_tag(%s): %s" % (tag, e.message))
    #    raise RuntimeError
    # time for NM to update based on deleted configs
    sleep(5)

def after_step(context, step):
    """Teardown after each step.
    Here we make screenshot and embed it (if one of formatters supports it)
    """
    sleep(1)
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
    Kill evolution (in order to make this reliable we send sigkill)
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
