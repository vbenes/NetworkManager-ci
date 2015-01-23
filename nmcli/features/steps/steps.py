# -*- coding: UTF-8 -*-
from behave import step
from time import sleep, time
import pexpect
import os
import exceptions
import re
import subprocess
from subprocess import Popen

# Helpers for the steps that leave the execution trace

def run(context, command, *a, **kw):
    try:
        output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT, *a, **kw)
        returncode = 0
        exception = None
    except subprocess.CalledProcessError as e:
        output = e.output
        returncode = e.returncode
        exception = e
    context.embed('text/plain', '$?=%d' % returncode, caption='%s result' % command)
    context.embed('text/plain', output, caption='%s output' % command)
    return output, returncode, exception

def command_output(context, command, *a, **kw):
    output, code, e = run(context, command, *a, **kw)
    if code != 0:
        raise e
    return output

def command_code(context, command, *a, **kw):
    _, code, _ = run(context, command, *a, **kw)
    return code

@step(u'{action} all "{what}" devices')
def do_device_stuff(context, action, what):
    command_code(context, "for dev in $(nmcli device status | grep '%s' | awk {'print $1'}); do nmcli device %s $dev; done" % (what, action))


@step(u'Activate connection')
def activate_connection(context):
    prompt = pexpect.spawn('activate')
    context.prompt = prompt


@step('Append "{line}" to ifcfg file "{name}"')
def append_to_ifcfg(context, line, name):
    cmd = 'sudo echo "%s" >> /etc/sysconfig/network-scripts/ifcfg-%s' % (line, name)
    command_code(context, cmd)


# @step(u'Add connection for a type "{typ}" named "{name}"')
# def add_connection(context, typ, name):
#     cli = pexpect.spawn('nmcli connection add type %s con-name %s' % (typ, name), logfile=context.log)
#     r = cli.expect(['Error', pexpect.EOF])
#     if r == 0:
#         raise Exception('Got an Error while adding %s connection %s' % (typ, name))
#     sleep(1)


@step(u'Add a secondary address to device "{device}" within the same subnet')
def add_secondary_addr_same_subnet(context, device):
    from netaddr import IPNetwork
    primary_ipn = IPNetwork(command_output(context, "ip a s %s | grep dynamic | awk '{print $2}'" % device))
    if str(primary_ipn.ip).split('.')[2] == str(primary_ipn.ip+1).split('.')[2]:
        secondary_ip = primary_ipn.ip+1
    else:
        secondary_ip = primary_ipn.ip-1
    assert command_code(context, 'ip addr add dev %s %s/%d' % (device, str(secondary_ip), primary_ipn.prefixlen)) == 0


@step(u'Add connection type "{typ}" named "{name}" for device "{ifname}"')
def add_connection_for_iface(context, typ, name, ifname):
    cli = pexpect.spawn('nmcli connection add type %s con-name %s ifname %s' % (typ, name, ifname), logfile=context.log)
    r = cli.expect(['Error', pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while adding %s connection %s for device %s' % (typ, name, ifname))
    sleep(1)


@step(u'Add a new connection of type "{typ}" ifname "{ifname}" and options "{options}"')
def add_new_default_connection(context, typ, ifname, options):
    pass


@step(u'Add a new connection of type "{typ}" and options "{options}"')
def add_new_default_connection_without_ifname(context, typ, options):
    cli = pexpect.spawn('nmcli connection add type %s %s' % (typ, options), logfile=context.log)
    if cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF]) == 0:
        raise Exception('Got an Error while creating connection of type %s with options %s' % (typ,options))


@step(u'Add infiniband port named "{name}" for device "{ifname}" with parent "{parent}" and p-key "{pkey}"')
def add_port(context, name, ifname, parent, pkey):
    cli = pexpect.spawn('nmcli connection add type infiniband con-name %s ifname %s parent %s p-key %s' % (name, ifname, parent, pkey), logfile=context.log)
    r = cli.expect(['Error', pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while adding %s connection %s for device %s' % (typ, name, ifname))
    sleep(1)


@step(u'Add slave connection for master "{master}" on device "{device}" named "{name}"')
def open_slave_connection(context, master, device, name):
    if master.find("team") != -1:
        cli = pexpect.spawn('nmcli connection add type team-slave ifname %s con-name %s master %s' % (device, name, master), logfile=context.log)
        r = cli.expect(['Error', pexpect.EOF])
    if master.find("bond") != -1:
        cli = pexpect.spawn('nmcli connection add type bond-slave ifname %s con-name %s master %s' % (device, name, master), logfile=context.log)
        r = cli.expect(['Error', pexpect.EOF])

    if r == 0:
        raise Exception('Got an Error while adding slave connection %s on device %s for master %s' % (name, device, master))
    sleep(2)


@step(u'Autocomplete "{cmd}" in bash and execute')
def autocomplete_command(context, cmd):
    bash = pexpect.spawn("bash")
    bash.send(cmd)
    bash.send('\t')
    sleep(1)
    bash.send('\r\n')
    sleep(1)
    bash.sendeof()


@step(u'Autoconnect warning is shown')
def autoconnect_warning(context):
    r = context.prompt.expect(["Saving the connection with \'autoconnect=yes\'. That might result in an immediate activation of the connection.\s+Do you still want to save?", "successfully"])
    if r != 0:
        raise Exception('Autoconnect warning was not shown')


@step(u'Backspace in editor')
def backspace_in_editor(context):
    context.prompt.send('\b')


@step(u'Send "{what}" in editor')
def send_sth_in_editor(context, what):
    context.prompt.send(what)


@step(u'Clear the text typed in editor')
def clear_text_typed(context):
    context.prompt.send("\b"*128)


@step(u'Bring "{action}" connection "{name}"')
def start_stop_connection(context, action, name):
    if action == "down":
        if command_code(context, "nmcli connection show --active |grep %s" %name) != 0:
            print "Warning: Connection is down no need to down it again"
            return
    method = command_output(context, "nmcli connection show %s|grep ipv4.method|awk '{print $2}'" %name).strip()
    if action == "up" and method in ["auto","disabled","link-local"]:
        if os.path.isfile('/tmp/nm_veth_configured'):
            device = command_output(context, "nmcli connection s %s |grep interface-name |awk '{print $2}'" % name).strip()
            command_code(context, 'ip link set dev %s up' % device)
            #command_code(context, 'ip link set dev %sp up' % device)

    cli = pexpect.spawn('nmcli connection %s id %s' % (action, name), logfile=context.log,  timeout=180)

    r = cli.expect(['Error', 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
    sleep(2)
    if r == 0:
        raise Exception('Got an Error while %sing connection %s' % (action, name))
    elif r == 1:
        raise Exception('nmcli connection %s %s timed out (90s)' % (action, name))
    elif r == 2:
        raise Exception('nmcli connection %s %s timed out (180s)' % (action, name))
    sleep(4)


@step(u'Bring up connection "{name}" for "{device}" device')
def start_connection_for_device(context, name, device):
    method = command_output(context, "nmcli connection show %s|grep ipv4.method|awk '{print $2}'" %name).strip()
    if method in ["auto","disabled","link-local"]:
        if os.path.isfile('/tmp/nm_veth_configured'):
            command_code(context, 'ip link set dev %s up' % device)
            #command_code(context, 'ip link set dev %sp up' % device)

    cli = pexpect.spawn('nmcli connection up id %s ifname %s' % (name, device), logfile=context.log,  timeout=180)
    r = cli.expect(['Error', 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while uping connection %s on %s' % (name, device))
    elif r == 1:
        raise Exception('nmcli connection up %s timed out (90s)' % (name))
    elif r == 2:
        raise Exception('nmcli connection up %s timed out (180s)' % (name))
    sleep(2)


@step(u'Bring up connection "{connection}"')
def bring_up_connection(context, connection):
    method = command_output(context, "nmcli connection show %s|grep ipv4.method|awk '{print $2}'" %connection).strip()
    if method in ["auto","disabled","link-local"]:
        if os.path.isfile('/tmp/nm_veth_configured'):
            device = command_output(context, "nmcli connection s %s |grep interface-name |awk '{print $2}'" % connection).strip()
            command_code(context, 'ip link set dev %s up' % device)
            #command_code(context, 'ip link set dev %sp up' % device)

    cli = pexpect.spawn('nmcli connection up %s' % connection, timeout = 180, logfile=context.log)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while upping connection %s' % connection)
    elif r == 1:
        raise Exception('nmcli connection up %s timed out (180s)' % connection)


@step(u'Bring up connection "{connection}" ignoring error')
def bring_up_connection_ignore_error(context, connection):
    method = command_output(context, "nmcli connection show %s|grep ipv4.method|awk '{print $2}'" %connection).strip()
    if method in ["auto","disabled","link-local"]:
        if os.path.isfile('/tmp/nm_veth_configured'):
            device = command_output(context, "nmcli connection s %s |grep interface-name |awk '{print $2}'" % connection).strip()
            command_code(context, 'ip link set dev %s up' % device)
            #command_code(context, 'ip link set dev %sp up' % device)

    cli = pexpect.spawn('nmcli connection up %s' % connection, timeout = 180, logfile=context.log)
    r = cli.expect([pexpect.EOF, pexpect.TIMEOUT])
    if r == 1:
        raise Exception('nmcli connection up %s timed out (180s)' % connection)
    sleep(4)


@step(u'Bring down connection "{connection}"')
def bring_down_connection(context, connection):
    cli = pexpect.spawn('nmcli connection down %s' % connection, timeout = 180, logfile=context.log)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while downing a connection %s' % connection)
    elif r == 1:
        raise Exception('nmcli connection down %s timed out (180s)' % connection)


@step(u'Bring down connection "{connection}" ignoring error')
def bring_down_connection_ignoring(context, connection):
    cli = pexpect.spawn('nmcli connection down %s' % connection, timeout = 180, logfile=context.log)
    r = cli.expect([pexpect.EOF, pexpect.TIMEOUT])
    if r == 1:
        raise Exception('nmcli connection down %s timed out (180s)' % connection)


@step(u'Check ipv6 connectivity is stable on assuming connection profile "{profile}" for device "{device}"')
def check_ipv6_connectivity_on_assumal(context, profile, device):
    address = command_output(context, "ip -6 a s %s | grep dynamic | awk '{print $2}' | cut -d '/' -f1" % device)
    assert command_code(context, 'systemctl stop NetworkManager.service') == 0
    assert command_code(context, "sed -i 's/UUID=/#UUID=/' /etc/sysconfig/network-scripts/ifcfg-%s" % profile)  == 0
    ping = pexpect.spawn('ping6 %s -i 0.2 -c 50' % address, logfile=context.log)
    sleep(1)
    assert command_code(context, 'systemctl start NetworkManager.service') == 0
    sleep(12)
    r = ping.expect(["0% packet loss", pexpect.EOF, pexpect.TIMEOUT])
    if r != 0:
        raise Exception('Had packet loss on pinging the address!')


@step(u'Check device route and prefix for "{dev}"')
def check_slaac_setup(context, dev):
    cmd = "sudo radvdump > /tmp/radvdump.txt"
    proc = Popen(cmd, shell=True)
    sleep(200)
    cmd = "sudo pkill -9 radvdump"
    command_code(context, cmd)
    dump = open("/tmp/radvdump.txt", "r")
    prefix = ""
    for line in dump.readlines():
        if line.find('prefix 2') != -1:
            prefix = line.split(' ')[1].strip()
            break

    cmd = "ip -6 route |grep %s" %prefix
    search = ""
    for line in command_output(context, cmd).split('\n'):
        if line.find(dev) != -1:
            search = line
            break

    device_route = "%s dev %s" %(prefix, dev)

    assert search.find(device_route) != -1, "Device route %s wasn't found. Just this was found %s" %(device_route, search)

    device_prefix = prefix.split('::')[1]
    cmd = 'ip a s %s |grep inet6| grep "scope global"' %dev
    ipv6_line = ""
    for line in command_output(context, cmd).split('\n'):
        if line.find('inet6'):
            ipv6_line = line
            break

    assert line.find(device_prefix) != -1, "Prefix %s wasn't found in %s" %(device_prefix, line)


@step(u'Check "{options}" are present in describe output for object "{obj}"')
def check_describe_output_in_editor(context, options, obj):
    options = options.split('|')
    context.prompt.sendline('describe %s' % obj)
    for opt in options:
        assert context.prompt.expect(["%s" % opt, pexpect.TIMEOUT], timeout=5) == 0 , "Option %s was not described!" % opt


@step(u'Check noted values "{i1}" and "{i2}" are the same')
def check_same_noted_values(context, i1, i2):
    assert context.noted[i1].strip() == context.noted[i2].strip(), "Noted values do not match!"


@step(u'Check noted output contains "{pattern}"')
def check_noted_output_contains(context, pattern):
    assert re.search(pattern, context.noted_value) is not None, "Noted output does not contain the pattern %s" % pattern


@step(u'Check if object item "{item}" has value "{value}" via print')
def value_printed(context, item, value):
    context.prompt.sendline('print')
    #sleep(2)
    if value == "current_time":
        t_int = int(time())
        t_str = str(t_int)
        value = t_str[:-3]
        print value

    context.prompt.expect('%s\s+%s' %(item, value))
    print context.prompt


@step(u'Check if "{name}" is active connection')
def is_active_connection(context, name):
    cli = pexpect.spawn('nmcli -t -f NAME connection show --active', logfile=context.log)
    r = cli.expect([name,pexpect.EOF])
    if r == 1:
        raise Exception('Connection %s is not active' % name)


@step(u'Check if "{name}" is not active connection')
def is_nonactive_connection(context, name):
    cli = pexpect.spawn('nmcli -t -f NAME connection show --active', logfile=context.log)
    r = cli.expect([name,pexpect.EOF])
    if r == 0:
        raise Exception('Connection %s is active' % name)


@step(u'Check ifcfg-name file created with noted connection name')
def check_ifcfg_exists(context):
    cat = pexpect.spawn('cat /etc/sysconfig/network-scripts/ifcfg-%s' % context.noted, logfile=context.log)
    cat.expect('NAME=%s' % context.noted)


@step(u'Check ifcfg-name file created for connection "{con_name}"')
def check_ifcfg_exists_given_device(context, con_name):
    cat = pexpect.spawn('cat /etc/sysconfig/network-scripts/ifcfg-%s' % con_name, logfile=context.log)
    cat.expect('NAME=%s' % con_name)


@step(u'Check bond "{bond}" in proc')
def check_bond_in_proc(context, bond):
    child = pexpect.spawn('cat /proc/net/bonding/%s ' % (bond) , logfile=context.log)
    assert child.expect(['Ethernet Channel Bonding Driver', pexpect.EOF]) == 0; "%s is not in proc" % bond


@step(u'Check slave "{slave}" in bond "{bond}" in proc')
def check_slave_in_bond_in_proc(context, slave, bond):
    child = pexpect.spawn('cat /proc/net/bonding/%s' % (bond), logfile=context.log )
    assert child.expect(["Slave Interface: %s\s+MII Status: up" % slave, pexpect.EOF]) == 0, "Slave %s is not in %s" % (slave, bond)

@step(u'Check slave "{slave}" in team "{team}" is "{state}"')
def check_slave_in_team_is_up(context, slave, team, state):
    #sleep(2)
    r = command_code(context, 'sudo teamdctl %s port present %s' %(team, slave))
    if state == "up":
        if r != 0:
            raise Exception('Device %s was not found in dump of team %s' % (slave, team))

    if state == "down":
        if r == 0:
            raise Exception('Device %s was found in dump of team %s' % (slave, team))

    # child = pexpect.spawn('sudo teamdctl %s state dump' % (team),  maxread=10000, logfile=context.log )
    # if state == "up":
    #     found = '"ifname"\:\s+"%s"' % slave
    #     r = child.expect([found, 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
    #     if r != 0:
    #         raise Exception('Device %s was not found in dump of team %s' % (slave, team))

    #     r = child.expect(['"up"\: true', '"ifname"', 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
    #     if r != 0:
    #         raise Exception('Got an Error while %sing connection %s' % (action, name))

    # if state == "down":
    #     r = child.expect([slave, 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
    #     if r == 0:
    #         raise Exception('Device %s was found in dump of team %s' % (slave, team))


@step(u'Check "{bond}" has "{slave}" in proc')
def check_slave_present_in_bond_in_proc(context, slave, bond):
    # DON'T USE THIS STEP UNLESS YOU HAVE A GOOD REASON!!
    # this is not looking for up state as arp connections are sometimes down.
    # it's always better to check whether slave is up
    child = pexpect.spawn('cat /proc/net/bonding/%s' % (bond), logfile=context.log )
    assert child.expect(["Slave Interface: %s\s+MII Status:" % slave, pexpect.EOF]) == 0, "Slave %s is not in %s" % (slave, bond)


@step(u'Check slave "{slave}" not in bond "{bond}" in proc')
def check_slave_not_in_bond_in_proc(context, slave, bond):
    child = pexpect.spawn('cat /proc/net/bonding/%s' % (bond), logfile=context.log )
    assert child.expect(["Slave Interface: %s\s+MII Status: up" % slave, pexpect.EOF]) != 0, "Slave %s is in %s" % (slave, bond)


@step(u'Check bond "{bond}" state is "{state}"')
def check_bond_state(context, bond, state):
    if command_code(context, 'ls /proc/net/bonding/%s' %bond) != 0 and state == "down":
        return
    child = pexpect.spawn('cat /proc/net/bonding/%s' % (bond) , logfile=context.log)
    assert child.expect(["MII Status: %s" %  state, pexpect.EOF]) == 0, "%s is not in %s state" % (bond, state)


@step(u'Check solicitation for "{dev}" in "{file}"')
def check_solicitation(context, dev, file):
    #file = '/tmp/solicitation.txt'
    #dev = 'enp0s25'
    cmd = "ip a s %s |grep ff:ff|awk {'print $2'}" %dev
    mac = ""
    for line in command_output(context, cmd).split('\n'):
        if line.find(':') != -1:
            mac = line.strip()

    mac_last_4bits = mac.split(':')[-2]+mac.split(':')[-1]
    dump = open(file, 'r')

    assert mac_last_4bits not in dump.readlines(), "Route solicitation from %s was found in tshark dump" % mac


@step(u'Check value saved message showed in editor')
def check_saved_in_editor(context):
    context.prompt.expect('successfully')


@step(u'Create 300 bridges and delete them')
def create_delete_bridges(context):
    i = 0
    while i < 300:
        Popen('brctl addbr br0' , shell=True).wait()
        Popen('ip addr add 1.1.1.1/24 dev br0' , shell=True).wait()
        Popen('ip link delete dev br0' , shell=True).wait()
        i += 1


@step(u'Configure dhcp server for subnet "{subnet}" with lease time "{lease}"')
def config_dhcp(context, subnet, lease):
    config = []
    config.append('default-lease-time %d;' %int(lease))
    config.append('max-lease-time %d;' %(int(lease)*2))
    config.append('subnet %s.0 netmask 255.255.255.0 {' %subnet)
    config.append('range %s.128 %s.250;' %(subnet, subnet))
    config.append('option routers %s.1;' %subnet)
    config.append('option domain-name "nodhcp";')
    config.append('option domain-name-servers %s.1, 8.8.8.8;}' %subnet)

    f = open('/etc/dhcp/dhcpd.conf','w')
    for line in config:
        f.write(line+'\n')
    f.close()



@step(u'Compare kernel and NM devices')
def compare_devices(context):
    # A tool that gets devices from Route Netlink & NetworkManager and
    # finds differencies (errors in NetworkManager external change tracking)
    #
    # Currently only takes master-slave relationships into account.
    # Could be easily extended...
    #
    # Lubomir Rintel <lrintel@redhat.com>

    from gi.repository import NM
    from pyroute2 import IPRoute

    def nm_devices():
        """
        Query devices from NetworkManager
        """

        client = NM.Client.new (None)

        devs = client.get_devices()
        devices = {}

        for c in devs:
            iface = c.get_iface()
            if iface:
                devices[c.get_iface()] = {}

        # Enslave devices
        for c in devs:
            typ = type(c).__name__

            if typ == 'DeviceBridge':
                slaves = c.get_slaves()
            elif typ == 'DeviceBond':
                slaves = c.get_slaves()
            elif typ == 'DeviceTeam':
                slaves = c.get_slaves()
            else:
                slaves = []

            for s in slaves:
                devices[s.get_iface()]['master'] = c.get_iface()

        return devices


    def rtnl_devices():
        """
        Query devices from route netlink
        """

        ip = IPRoute()
        devs = ip.get_links()
        ip.close()

        names = {}
        devices = {}

        for l in devs:
            names[l['index']] = l.get_attr('IFLA_IFNAME')

        for l in devs:
            master = l.get_attr('IFLA_MASTER')
            name = names[l['index']]

            devices[name] = {}
            if master:
                devices[name]['master'] = names[master]

        return devices

    def deep_compare(a_desc, a, b_desc, b):
        """
        Deeply compare structures
        """

        ret = True;

        a_type = type(a).__name__
        b_type = type(b).__name__

        if a_type != b_type:
            print ('%s is a %s whereas %s is a %s' % (a_desc, a_type,
                                                      b_desc, b_type))
            return False

        if a_type == 'dict':
            for a_key in a.keys():
                if b.has_key(a_key):
                    if not deep_compare(a_desc + '.' + a_key, a[a_key],
                                b_desc + '.' + a_key, b[a_key]):
                        ret = False
                else:
                    print ('%s does not have %s' % (b_desc, a_key))
                    ret = False

            for b_key in b.keys():
                if not a.has_key(b_key):
                    print ('%s does not have %s' % (a_desc, b_key))
                    ret = False
        else:
            if a != b:
                print ('%s == %s while %s == %s' % (a_desc, a,
                                                    b_desc, b))
                ret = False

        return ret

    assert deep_compare ('NM', nm_devices(), 'RTNL', rtnl_devices()), \
            "Kernel and NetworkManager's device lists are different"


@step(u'Connect device "{device}"')
def connect_device(context, device):
    cli = pexpect.spawn('nmcli device con %s' % device, timeout = 180, logfile=context.log)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while connecting a device %s' % device)
    elif r == 1:
        raise Exception('nmcli device connect %s timed out (180s)' % device)


@step(u'Connect wifi device to "{network}" network')
def connect_wifi_device(context, network):
    cli = pexpect.spawn('nmcli device wifi connect "%s"' % network, timeout = 180, logfile=context.log)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while connecting to network %s' % network)
    elif r == 1:
        raise Exception('nmcli device wifi connect ... timed out (180s)')


@step(u'Connect wifi device to "{network}" network with options "{options}"')
def connect_wifi_device_w_options(context, network, options):
    cli = pexpect.spawn('nmcli device wifi connect "%s" %s' % (network, options), timeout = 180, logfile=context.log)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while connecting to network %s' % network)
    elif r == 1:
        raise Exception('nmcli device wifi connect ... timed out (180s)')


@step(u'Delete connection "{connection}"')
def delete_connection(context,connection):
    cli = pexpect.spawn('nmcli connection delete %s' % connection, timeout = 95, logfile=context.log)
    res = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if res == 0:
        raise Exception('Got an Error while deleting connection %s' % connection)
    elif res == 1:
        raise Exception('Deleting connecion %s timed out (95s)' % connection)


@step(u'Delete connection "{name}" and hit enter')
def delete_connection_with_enter(context, name):
    command_code(context, 'nmcli connection delete id %s' %name)
    sleep(5)
    context.prompt.send('\n')
    sleep(2)
    assert context.prompt.isalive() is True, 'Something went wrong'


@step(u'Disconnect device "{name}"')
def disconnect_connection(context, name):
    cli = pexpect.spawn('nmcli device disconnect %s' % name, logfile=context.log,  timeout=180)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while disconnecting device %s' % name)
    elif r == 1:
        raise Exception('nmcli disconnect %s timed out (180s)' % name)
    sleep(1)


@step(u'Enter in editor')
def enter_in_editor(context):
    context.prompt.send('\n')


@step(u'Expect "{what}"')
def expect(context, what):
    context.prompt.expect(what)


@step(u'Error appeared in editor')
def error_appeared_in_editor(context):
    r = context.prompt.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 2 or r == 1:
        raise Exception('Did not see an Error in editor')


@step(u'Error type "{type}" shown in editor')
def check_error_in_editor(context, type):
    context.prompt.expect("%s" % type)


@step(u'Error type "{type}" while saving in editor')
def check_error_while_saving_in_editor(context, type):
    context.prompt.expect("%s" % type)


@step(u'Execute "{command}"')
def execute_command(context, command):
    command_code(context, command)
    sleep(0.3)

@step(u'Execute "{command}" without waiting for process to finish')
def execute_command(context, command):
    Popen(command, shell=True)


@step(u'Fail up connection "{name}" for "{device}"')
def fail_up_connection_for_device(context, name, device):
    if os.path.isfile('/tmp/nm_veth_configured'):
        command_code(context, 'ip link set dev %s up' %device)

    cli = pexpect.spawn('nmcli connection up id %s ifname %s' % (name, device), logfile=context.log,  timeout=180)
    r = cli.expect(['Error', 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
    if r == 3:
        raise Exception('nmcli connection up %s for device %s was succesfull. this should not happen' % (name, device))
    sleep(1)


@step(u'Finish "{command}"')
def wait_for_process(context, command):
    assert command_code(context, command) == 0
    sleep(0.1)


@step(u'Global temporary ip is not based on mac of device "{dev}"')
def global_tem_address_check(context, dev):
    cmd = "ip a s %s" %dev
    mac = ""
    temp_ipv6 = ""
    ipv6 = ""
    for line in command_output(context,cmd).split('\n'):
        if line.find('brd ff:ff:ff:ff:ff:ff') != -1:
            mac = line.split()[1]
        if line.find('scope global temporary dynamic') != -1:
            temp_ipv6 = line.split()[1]
        if line.find('scope global dynamic') != -1:
            ipv6 = line.split()[1]

    assert temp_ipv6 != ipv6, 'IPV6 Address are similar!'
    temp_ipv6_end = temp_ipv6.split('/')[0].split(':')[-1]
    mac_end = mac.split(':')[-2]+mac.split(':')[-1]
    assert temp_ipv6_end != mac_end, 'Mac and tmp Ipv6 are similar in the end %s..%s'


@step(u'Hostname is visible in log "{log}"')
def hostname_visible(context, log):
    cmd = "grep $(hostname -s) %s" %log
    assert command_code(context, cmd) == 0, 'Hostname was not visible in log'


@step(u'Hostname is not visible in log "{log}"')
def hostname_visible(context, log):
    cmd = "grep $(hostname -s) %s" %log
    assert command_code(context, cmd) == 1, 'Hostname was visible in log'


@step(u'ifcfg-"{con_name}" file does not exist')
def ifcfg_doesnt_exist(context, con_name):
    cat = pexpect.spawn('cat /etc/sysconfig/network-scripts/ifcfg-%s' % con_name, logfile=context.log)
    assert cat.expect('No such file') == 0, 'Ifcfg-%s exists!' % con_name


@step(u'Lifetimes are slightly smaller than "{valid_lft}" and "{pref_lft}" for device "{device}"')
def correct_lifetime(context, valid_lft, pref_lft, device):
    command = "ip a s %s |grep -A 2 inet6| grep -A 2 dynamic |grep valid_lft |awk '{print $2}'" % device
    valid = command_output(context, command)
    command = "ip a s %s |grep -A 2 inet6| grep -A 2 dynamic |grep valid_lft |awk '{print $4}'" % device
    pref = command_output(context, command)
    valid = valid.strip()
    valid = valid.replace('sec', '')
    pref = pref.strip()
    pref = pref.replace('sec', '')
    assert int(valid) != int(pref)
    assert int(valid) <= int(valid_lft) and int(valid_lft) >= int(valid)-20
    assert int(pref) <= int(pref_lft) and int(pref_lft) >= int(pref)-20


@step(u'Look for "{content}" in tailed file')
def find_tailing(context, content):
    if context.tail.expect([content, pexpect.TIMEOUT, pexpect.EOF]) == 1:
        raise Exception('Did not see the "%s" in tail output before timeout (180s)' % content)


@step(u'Mode missing message shown in editor')
def mode_missing_in_editor(context):
    context.prompt.expect("Error: connection verification failed: bond.options: mandatory option 'mode' is missing")


@step(u'Network trafic "{state}" dropped')
def network_dropped(context, state):
    if state == "is":
        assert command_code(context, 'ping -c 1 -W 1 nix.cz') != 0
    if state == "is not":
        assert command_code(context, 'ping -c 1 -W 1 nix.cz') == 0


@step(u'Network trafic "{state}" dropped on "{device}"')
def network_dropped_two(context, state, device):
    if state == "is":
        assert command_code(context, 'ping -c 2 -I %s -W 1 10.11.5.19' % device) != 0
    if state == "is not":
        assert command_code(context, 'ping -c 2 -I %s -W 1 10.11.5.19' % device) == 0


@step(u'No error appeared in editor')
def no_error_appeared_in_editor(context):
    r = context.prompt.expect([pexpect.TIMEOUT, pexpect.EOF, 'Error'], timeout=5)
    if r == 2:
        raise Exception('Got an Error in editor')


@step(u'Note the "{prop}" property from editor print output')
def note_print_property(context, prop):
    category, item = prop.split('.')
    context.prompt.sendline('print %s' % category)
    context.prompt.expect('%s.%s:\s+(\S+)' % (category, item))
    context.noted = context.prompt.match.group(1)
    print context.noted


@step(u'Note the "{prop}" property from ifconfig output for device "{device}"')
def note_print_property(context, prop, device):
    ifc = pexpect.spawn('ifconfig %s' % device, logfile=context.log)
    ifc.expect('%s\s(\S+)' % prop)
    context.noted = ifc.match.group(1)
    print context.noted


@step(u'Noted value contains "{pattern}"')
def note_print_property_b(context, pattern):
    assert re.search(pattern, context.noted) is not None, "Noted value does not match the pattern!"


@step(u'Note the output of "{command}" as value "{index}"')
def note_the_output_as(context, command, index):
    if not hasattr(context, 'noted'):
        context.noted = {}
    context.noted[index] = command_output(context, command)


@step(u'Note the output of "{command}"')
def note_the_output_of(context, command):
    context.noted_value = command_output(context, command)


@step(u'Open editor for connection "{con_name}"')
def open_editor_for_connection(context, con_name):
    sleep(0.2)
    prompt = pexpect.spawn('nmcli connection ed %s' % con_name, logfile=context.log)
    context.prompt = prompt
    r = prompt.expect([con_name, 'Error'])
    if r == 1:
        raise Exception('Got an Error while opening profile %s' % (con_name))


@step(u'Open editor for "{con_name}" with timeout')
def open_editor_for_connection_with_timeout(context, con_name):
    prompt = pexpect.spawn('nmcli connection ed %s' % (con_name), logfile=context.log, maxread=6000, timeout=5)
    sleep(2)
    context.prompt = prompt
    r = prompt.expect(['Error', con_name])
    if r == 0:
        raise Exception('Got an Error while opening profile %s' % (con_name))


@step(u'Open editor for new connection "{con_name}" type "{type}"')
def open_editor_for_connection_type(context, con_name, type):
    prompt = pexpect.spawn('nmcli connection ed type %s con-name %s' % (type, con_name), logfile=context.log, maxread=6000)
    context.prompt = prompt
    sleep(1)
    r = prompt.expect(['nmcli interactive connection editor','Error'])
    if r != 0:
        raise Exception('Got an Error while opening  %s profile %s' % (type, con_name))


@step(u'Open editor for a type "{typ}"')
def open_editor_for_a_type(context, typ):
    prompt = pexpect.spawn('nmcli connection edit type %s con-name %s0' % (typ, typ), logfile=context.log)
    context.prompt = prompt


@step(u'Open interactive connection addition mode for a type "{typ}"')
def open_interactive_for_a_type(context, typ):
    prompt = pexpect.spawn('nmcli -a connection add type %s' % typ, timeout = 5, logfile=context.log)
    context.prompt = prompt


@step(u'Open interactive connection addition mode')
def open_interactive(context):
    prompt = pexpect.spawn('nmcli -a connection add', timeout = 5, logfile=context.log)
    context.prompt = prompt


@step(u'Open wizard for adding new connection')
def add_novice_connection(context):
    prompt = pexpect.spawn("nmcli -a connection add", logfile=context.log)
    context.prompt = prompt


@step(u'"{pattern}" is visible with command "{command}"')
def check_pattern_visible_with_command(context, pattern, command):
    sleep(1) # time for all to get set
    cmd = '/bin/bash -c "%s"' %command
    ifconfig = pexpect.spawn(cmd, maxread=100000, logfile=context.log)
    assert ifconfig.expect([pattern, pexpect.EOF]) == 0, 'pattern %s is not visible with %s' % (pattern, command)


@step(u'"{pattern}" is visible with command "{command}" in "{seconds}" seconds')
def check_pattern_visible_with_command_in_time(context, pattern, command, seconds):
    seconds = int(seconds)
    orig_seconds = seconds
    while seconds > 0:
        ifconfig = pexpect.spawn(command, timeout = 180, logfile=context.log)
        if ifconfig.expect([pattern, pexpect.EOF]) == 0:
            return True
        seconds = seconds - 1
        sleep(1)
    raise Exception('Did not see the pattern %s in %d seconds' % (pattern, orig_seconds))


@step(u'"{pattern}" is visible with command "{command}" for full "{seconds}" seconds')
def check_pattern_visible_with_command_fortime(context, pattern, command, seconds):
    seconds = int(seconds)
    orig_seconds = seconds
    while seconds > 0:
        ifconfig = pexpect.spawn(command, timeout = 180, logfile=context.log)
        if ifconfig.expect([pattern, pexpect.EOF]) == 0:
            pass
        else:
            raise Exception('Pattern %s disappeared after %d seconds' % (pattern, orig_seconds-seconds))
        seconds = seconds - 1
        sleep(1)


@step(u'"{pattern}" is not visible with command "{command}" in "{seconds}" seconds')
def check_pattern_not_visible_with_command_in_time(context, pattern, command, seconds):
    seconds = int(seconds)
    orig_seconds = seconds
    while seconds > 0:
        ifconfig = pexpect.spawn(command, timeout = 180, logfile=context.log)
        if ifconfig.expect([pattern, pexpect.EOF]) != 0:
            return True
        seconds = seconds - 1
        sleep(1)
    raise Exception('Did still see the pattern %s after %d seconds' % (pattern, orig_seconds))

@step(u'"{pattern}" is not visible with command "{command}"')
def check_pattern_not_visible_with_command(context, pattern, command):
    sleep(1) # time for all to get set
    cmd = '/bin/bash -c "%s"' %command
    ifconfig = pexpect.spawn(cmd, maxread=100000, logfile=context.log)
    assert ifconfig.expect([pattern, pexpect.EOF]) != 0, 'pattern %s still visible with %s' % (pattern, command)


@step(u'"{pattern}" is visible with tab after "{command}"')
def check_pattern_visible_with_tab_after_command(context, pattern, command):
    exp = pexpect.spawn('/bin/bash', logfile=context.log)
    exp.send(command)
    exp.sendcontrol('i')
    exp.sendcontrol('i')
    exp.sendcontrol('i')
    exp.sendeof()

    assert exp.expect([pattern, pexpect.EOF]) == 0, 'pattern %s is not visible with "%s"' % (pattern, command)


@step(u'"{pattern}" is not visible with tab after "{command}"')
def check_pattern_not_visible_with_tab_after_command(context, pattern, command):
    exp = pexpect.spawn('/bin/bash', logfile=context.log)
    exp.send(command)
    exp.sendcontrol('i')
    exp.sendcontrol('i')
    exp.sendcontrol('i')
    exp.sendeof()

    assert exp.expect([pattern, pexpect.EOF, pexpect.TIMEOUT]) != 0, 'pattern %s is visible with "%s"' % (pattern, command)


@step(u'Ping "{domain}"')
def ping_domain(context, domain):
    ping = pexpect.spawn('ping -c 2 %s' %domain, logfile=context.log)
    ping.expect([pexpect.EOF])
    ping.close()
    assert ping.exitstatus == 0


@step(u'Ping "{domain}" from "{device}" device')
def ping_domain_from_device(context, domain, device):
    ping = pexpect.spawn('ping -c 2 -I %s %s' %(device, domain), logfile=context.log)
    ping.expect([pexpect.EOF])
    ping.close()
    assert ping.exitstatus == 0


@step(u'Ping6 "{domain}"')
def ping6_domain(context, domain):
    ping = pexpect.spawn('ping6 -c 2 %s' %domain, logfile=context.log)
    ping.expect([pexpect.EOF])
    ping.close()
    assert ping.exitstatus == 0


@step(u'Prepare connection')
def prepare_connection(context):
    context.execute_steps(u"""
        * Submit "set ipv4.method manual" in editor
        * Submit "set ipv4.addresses 1.2.3.4/24" in editor
        * Submit "set ipv4.gateway 1.1.1.1" in editor
        * Submit "set ipv4.never-default yes" in editor
        * Submit "set ipv6.method ignore" in editor
    """)



@step(u'Prepare veth pairs "{pairs_array}" bridged over "{bridge}"')
def prepare_veths(context, pairs_array, bridge):
    pairs = []
    for pair in pairs_array.split(','):
        pairs.append(pair.strip())

    command_code(context, "sudo brctl addbr %s"% bridge)
    command_code(context, "sudo ip link set dev %s up"% bridge)
    for pair in pairs:
        command_code(context, "ip link add %s type veth peer name %sp" %(pair, pair))
        command_code(context, "brctl addif vethbr %sp" %pair)
        command_code(context, "ip link set dev %s up" % pair)
        command_code(context, "ip link set dev %sp up" % pair)


@step(u'Print in editor')
def print_in_editor(context):
    context.prompt.sendline('print')


@step(u'Prompt is not running')
def prompt_is_not_running(context):
    sleep(1)
    assert context.prompt.isalive() is False


@step(u'Quit editor')
def quit_editor(context):
    context.prompt.sendline('quit')
    #sleep(0.3)


@step(u'Reboot')
def reboot(context):
    for x in xrange(1,10):
        command_code(context, "sudo ip link set dev eth%d down" %int(x))
        command_code(context, "sudo ip addr flush dev eth%d" %int(x))
    command_code(context, "nmcli device disconnect nm-bond")
    command_code(context, "nmcli device disconnect nm-team")
    sleep(4)
    assert command_code(context, "sudo service NetworkManager restart") == 0
    sleep(4)


@step(u'Restart NM')
def restart_NM(context):
    sleep(1)
    command_code(context, "service NetworkManager restart") == 0
    if os.path.isfile('/tmp/nm_veth_configured'):
        command_code(context, 'ip link set dev eth0 up')
        command_code(context, 'ip link set dev eth0p up')
        command_code(context, 'ip link set dev eth99 up')
        command_code(context, 'ip link set dev eth99p up')
        command_code(context, 'ip link set dev eth99p up')
        command_code(context, 'ip link set dev outbr up')
        command_code(context, 'ip link set dev isobr up')
        command_code(context, 'nmcli c modify dhcp-srv ipv4.method shared')
        command_code(context, 'nmcli c modify dhcp-srv ipv4.addresses 192.168.100.1/24')
        command_code(context, 'nmcli con up dhcp-srv')
        command_code(context, 'nmcli con up testeth0')

    sleep(4)



@step(u'Run child "{command}"')
def run_child_process(context, command):
    Popen(command, shell=True)


@step(u'Save in editor')
def save_in_editor(context):
    context.prompt.sendline('save')
    sleep(0.2)


@step(u'See Error while saving in editor')
def check_error_while_saving_in_editor_2(context):
    context.prompt.expect("Error")


@step(u'Send lifetime scapy packet')
def send_packet(context):
    from scapy.all import get_if_hwaddr
    from scapy.all import sendp, Ether, IPv6
    from scapy.all import ICMPv6ND_RA
    from scapy.all import ICMPv6NDOptPrefixInfo

    in_if = "test10"
    out_if = "test11"

    p = Ether(dst=get_if_hwaddr(out_if), src=get_if_hwaddr(in_if))
    p /= IPv6(dst="ff02::1")
    p /= ICMPv6ND_RA()
    p /= ICMPv6NDOptPrefixInfo(prefix="fd00:8086:1337::", prefixlen=64, validlifetime=3600, preferredlifetime=1800)
    sendp(p, iface=in_if)
    sendp(p, iface=in_if)

    sleep(3)


@step(u'Set a property named "{name}" to "{value}" in editor')
def set_property_in_editor(context, name, value):
    if value == 'noted-value':
        context.prompt.sendline('set %s %s' % (name,context.noted))
    else:
        context.prompt.sendline('set %s %s' % (name,value))


@step(u'Set logging for "{domain}" to "{level}"')
def set_logging(context, domain, level):
    if level == " ":
        cli = pexpect.spawn('nmcli g l domains %s' % (domain), timeout = 60, logfile=context.log)
    else:
        cli = pexpect.spawn('nmcli g l level %s domains %s' % (level, domain), timeout = 60, logfile=context.log)

    r = cli.expect(['Error', 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
    if r != 3:
        raise Exception('Something bad happened when changing log level')

@step(u'Set default DCB options')
def set_default_dcb(context):
    context.execute_steps(u"""
        * Submit "set dcb.app-fcoe-flags 7" in editor
        * Submit "set dcb.app-fcoe-priority 7" in editor
        * Submit "set dcb.app-fcoe-mode vn2vn" in editor
        * Submit "set dcb.app-iscsi-flags 7" in editor
        * Submit "set dcb.app-iscsi-priority 6" in editor
        * Submit "set dcb.app-fip-flags 7" in editor
        * Submit "set dcb.app-fip-priority 2" in editor

        * Submit "set dcb.priority-flow-control-flags 7" in editor
        * Submit "set dcb.priority-flow-control 1,0,0,1,1,0,1,0" in editor
        * Submit "set dcb.priority-group-flags 7" in editor
        * Submit "set dcb.priority-group-id 0,0,0,0,1,1,1,1" in editor
        * Submit "set dcb.priority-group-bandwidth 13,13,13,13,12,12,12,12" in editor
        * Submit "set dcb.priority-bandwidth 100,100,100,100,100,100,100,100" in editor
        * Submit "set dcb.priority-traffic-class 7,6,5,4,3,2,1,0" in editor
    """)


@step(u'Submit "{what}"')
def submit(context, what):
    if what == 'noted-value':
        context.prompt.sendline(context.noted)
    elif what == '<enter>':
        context.prompt.send("\n")
    else:
        context.prompt.sendline(what)


@step(u'Submit "{command}" in editor')
def submit_in_editor(context, command):
    command = command.replace('\\','')
    context.prompt.sendline("%s" % command)


@step(u'Submit team \'{command}\' in editor')
def submit_team_command_in_editor(context, command):
    context.prompt.sendline('%s' % command)


@step(u'Spawn "{command}" command')
def spawn_command(context, command):
    context.prompt = pexpect.spawn(command, logfile=context.log)
    if not hasattr(context, 'spawned_processes'):
        context.spawned_processes = {}
    context.spawned_processes[command] = context.prompt


@step(u'Start generic connection "{connection}" for "{device}"')
def start_generic_connection(context, connection, device):
    if os.path.isfile('/tmp/nm_veth_configured'):
        command_code(context, 'ip link set dev %s up' %device)

    cli = pexpect.spawn('nmcli connection up %s ifname %s' % (connection, device), timeout = 180, logfile=context.log)
    r = cli.expect([pexpect.EOF, pexpect.TIMEOUT])
    if r != 0:
        raise Exception('nmcli connection up %s timed out (180s)' % connection)
    sleep(4)


@step(u'Start tailing file "{archivo}"')
def start_tailing(context, archivo):
    context.tail = pexpect.spawn('sudo tail -f %s' % archivo, timeout = 180, logfile=context.log)
    sleep(0.3)


@step(u'Start following journal')
def start_tailing_journal(context):
    context.journal = pexpect.spawn('sudo journalctl --follow -o cat', timeout = 180, logfile=context.log)
    sleep(0.3)


@step(u'Look for "{content}" in journal')
def find_tailing_journal(context, content):
    if context.journal.expect([content, pexpect.TIMEOUT, pexpect.EOF]) == 1:
        raise Exception('Did not see the "%s" in journal output before timeout (180s)' % content)


@step(u'Team "{team}" is down')
def team_is_down(context, team):
    cmd = pexpect.spawn('teamdctl %s state dump' %team, logfile=context.log)
    print command_code(context, 'teamdctl %s state dump' %team)
    assert command_code(context, 'teamdctl %s state dump' %team) != 0, 'team "%s" exists' % (team)


@step(u'Terminate spawned process "{command}"')
def terminate_spawned_process(context, command):
    assert context.spawned_processes[command].terminate() == True


@step(u'Unable to ping "{domain}"')
def cannot_ping_domain(context, domain):
    ping = pexpect.spawn('ping -c 2 %s' %domain, logfile=context.log)
    ping.expect([pexpect.EOF])
    ping.close()
    assert ping.exitstatus != 0


@step(u'Unable to ping "{domain}" from "{device}" device')
def cannot_ping_domain_from_device(context, domain, device):
    ping = pexpect.spawn('ping -c 2 -I %s %s ' %(device, domain), logfile=context.log)
    ping.expect([pexpect.EOF])
    ping.close()
    assert ping.exitstatus != 0


@step(u'Unable to ping6 "{domain}"')
def cannot_ping6_domain(context, domain):
    ping = pexpect.spawn('ping6 -c 2 %s' %domain, logfile=context.log)
    ping.expect([pexpect.EOF])
    ping.close()
    assert ping.exitstatus != 0


@step(u'"{user}" is able to see connection "{name}"')
def is_readable(context, user, name):
    cli = pexpect.spawn('sudo -u %s nmcli connection show configured %s' %(user, name))
    if cli.expect(['connection.id:\s+gsm', 'Error', pexpect.TIMEOUT, pexpect.EOF]) != 0:
        raise Exception('Error while getting connection %s' % name)


@step(u'"{user}" is not able to see connection "{name}"')
def is_not_readable(context, user, name):
    cli = pexpect.spawn('sudo -u %s nmcli connection show configured %s' %(user, name))
    if cli.expect(['connection.id:\s+gsm', 'Error', pexpect.TIMEOUT, pexpect.EOF]) == 0:
        raise Exception('Connection %s is readable even if it should not be %s' % name)


@step(u'Value saved message showed in editor')
def check_saved_in_editor(context):
    context.prompt.expect('successfully')


@step(u'"{value}" appeared in editor')
def value_appeared_in_editor(context, value):
    r = context.prompt.expect([value, pexpect.TIMEOUT, pexpect.EOF])
    if r == 2 or r == 1:
        raise Exception('Did not see "%s" in editor' % value)


@step(u'vxlan device "{dev}" check')
def vxlan_device_check(context, dev):
    import dbus, sys

    bus = dbus.SystemBus()
    proxy = bus.get_object("org.freedesktop.NetworkManager", "/org/freedesktop/NetworkManager")
    manager = dbus.Interface(proxy, "org.freedesktop.NetworkManager")


    devices = manager.GetDevices()
    assert devices, "Failed to find any vxlan interface"

    for d in devices:
        dev_proxy = bus.get_object("org.freedesktop.NetworkManager", d)
        prop_iface = dbus.Interface(dev_proxy, "org.freedesktop.DBus.Properties")
        props = prop_iface.GetAll("org.freedesktop.NetworkManager.Device")

        if props['Interface'] != dev:
            continue

        vxlan = prop_iface.GetAll("org.freedesktop.NetworkManager.Device.Vxlan")

        assert vxlan['Id'] == 42, "bad id '%s'" % vxlan['Id']
        assert vxlan['Group'] == "239.1.1.1", "bad group '%s'" % vxlan['Group']

        # Get parent
        parent_proxy = bus.get_object("org.freedesktop.NetworkManager", vxlan['Parent'])
        parent_prop_iface = dbus.Interface(parent_proxy, "org.freedesktop.DBus.Properties")
        parent_props = parent_prop_iface.GetAll("org.freedesktop.NetworkManager.Device")

        assert parent_props['Interface'] == "eth1", "bad parent '%s'" % parent_props['Interface']


@step(u'Wait for at least "{secs}" seconds')
def wait_for_x_seconds(context,secs):
    sleep(int(secs))
    assert True


@step(u'Write dispatcher "{path}" file with params "{params}"')
@step(u'Write dispatcher "{path}" file')
def write_dispatcher_file(context, path, params=None):
    disp_file  = '/etc/NetworkManager/dispatcher.d/%s' % path
    f = open(disp_file,'w')
    f.write('#!/bin/bash\n')
    if params:
        f.write(params)
    f.write('\necho $2 >> /tmp/dispatcher.txt\n')
    f.close()
    command_code(context, 'chmod +x %s' % disp_file)
    sleep(1)


@step(u'Wrong bond options message shown in editor')
def wrong_bond_options_in_editor(context):
    context.prompt.expect("Error: failed to set 'options' property:")
