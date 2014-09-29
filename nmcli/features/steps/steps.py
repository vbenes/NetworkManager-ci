# -*- coding: UTF-8 -*-
from behave import step
from time import sleep, time
import pexpect
import os
import exceptions
import re
from subprocess import check_output, Popen, call, PIPE


@step(u'{action} all "{what}" devices')
def do_device_stuff(context, action, what):
    os.system("for dev in $(nmcli device status | grep '%s' | awk {'print $1'}); do nmcli device %s $dev; done" % (what, action))


@step(u'Activate connection')
def activate_connection(context):
    prompt = pexpect.spawn('activate')
    context.prompt = prompt


@step('Append "{line}" to ifcfg file "{name}"')
def append_to_ifcfg(context, line, name):
    cmd = 'sudo echo "%s" >> /etc/sysconfig/network-scripts/ifcfg-%s' % (line, name)
    os.system(cmd)


# @step(u'Add connection for a type "{typ}" named "{name}"')
# def add_connection(context, typ, name):
#     cli = pexpect.spawn('nmcli connection add type %s con-name %s' % (typ, name), logfile=context.log)
#     r = cli.expect(['Error', pexpect.EOF])
#     if r == 0:
#         raise Exception('Got an Error while adding %s connection %s' % (typ, name))
#     sleep(1)


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
        if os.system("nmcli connection show --active |grep %s" %name) != 0:
            print "Warning: Connection is down no need to down it again"
            return
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
    cli = pexpect.spawn('nmcli connection up %s' % connection, timeout = 180, logfile=context.log)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while upping connection %s' % connection)
    elif r == 1:
        raise Exception('nmcli connection up %s timed out (180s)' % connection)


@step(u'Bring up connection "{connection}" ignoring error')
def bring_up_connection_ignore_error(context, connection):
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


@step(u'Change NM profile plugin to ifcfg-rh')
def change_to_keyfile(context):
    os.system("sudo sh -c \"echo '[main]\nplugins=ifcfg-rh' > /etc/NetworkManager/NetworkManager.conf\" ")


@step(u'Check device route and prefix for "{dev}"')
def check_slaac_setup(context, dev):
    cmd = "sudo radvdump > /tmp/radvdump.txt"
    proc = Popen(cmd, shell=True)
    sleep(104)
    cmd = "sudo pkill radvdump"
    Popen(cmd, shell=True).wait()
    dump = open("/tmp/radvdump.txt", "r")
    prefix = ""
    for line in dump.readlines():
        if line.find('prefix 2') != -1:
            prefix = line.split(' ')[1].strip()
            break

    cmd = "ip -6 route |grep %s" %prefix
    grep = Popen(cmd, shell=True, stdout=PIPE)
    grep.wait()
    search = ""
    for line in grep.stdout:
        if line.find(dev) != -1:
            search = line
            break

    device_route = "%s dev %s" %(prefix, dev)

    assert search.find(device_route) != -1, "Device route %s wasn't found. Just this was found %s" %(device_route, search)

    device_prefix = prefix.split('::')[1]
    cmd = 'ip a s %s |grep inet6| grep "scope global"' %dev
    ip = Popen(cmd, shell=True, stdout=PIPE)
    ip.wait()
    ipv6_line = ""
    for line in ip.stdout:
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
    sleep(2)
    child = pexpect.spawn('sudo teamdctl %s state dump' % (team),  maxread=10000, logfile=context.log )
    if state == "up":
        found = '"ifname"\: "%s"' % slave
        r = child.expect([found, 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
        if r != 0:
            raise Exception('Device %s was not found in dump of team %s' % (slave, team))

        r = child.expect(['"up"\: true', '"ifname"', 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
        if r != 0:
            raise Exception('Got an Error while %sing connection %s' % (action, name))

    if state == "down":
        r = child.expect([slave, 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
        if r == 0:
            raise Exception('Device %s was found in dump of team %s' % (slave, team))


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
    if os.system('ls /proc/net/bonding/%s' %bond) != 0 and state == "down":
        return
    child = pexpect.spawn('cat /proc/net/bonding/%s' % (bond) , logfile=context.log)
    assert child.expect(["MII Status: %s" %  state, pexpect.EOF]) == 0, "%s is not in %s state" % (bond, state)


@step(u'Check solicitation for "{dev}" in "{file}"')
def check_solicitation(context, dev, file):
    #file = '/tmp/solicitation.txt'
    #dev = 'enp0s25'
    cmd = "ip a s %s |grep ff:ff|awk {'print $2'}" %dev
    proc = Popen(cmd, shell=True, stdout=PIPE)
    proc.wait()
    mac = ""
    for line in proc.stdout:
        if line.find(':') != -1:
            mac = line.strip()

    mac_last_4bits = mac.split(':')[-2]+mac.split(':')[-1]
    dump = open(file, 'r')

    assert mac_last_4bits not in dump.readlines(), "Route solicitation from %s was found in tshark dump" % mac


@step(u'Check value saved message showed in editor')
def check_saved_in_editor(context):
    context.prompt.expect('successfully')


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
    os.system('nmcli connection delete id %s' %name)
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
    os.system(command)
    sleep(0.2)

@step(u'Execute "{command}" without waiting for process to finish')
def execute_command(context, command):
    Popen(command, shell=True)


@step(u'Fail up connection "{name}" for "{device}"')
def fail_up_connection_for_device(context, name, device):
    cli = pexpect.spawn('nmcli connection up id %s ifname %s' % (name, device), logfile=context.log,  timeout=180)
    r = cli.expect(['Error', 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
    if r == 3:
        raise Exception('nmcli connection up %s for device %s was succesfull. this should not happen' % (name, device))
    sleep(1)


@step(u'Finish "{command}"')
def wait_for_process(context, command):
    assert call(command, shell=True) == 0


@step(u'Global temporary ip is not based on mac of device "{dev}"')
def global_tem_address_check(context, dev):
    cmd = "ip a s %s" %dev
    pexpect.spawn(cmd, maxread=20000, logfile=context.log)
    proc = Popen(cmd, shell=True, stdout=PIPE)
    mac = ""
    temp_ipv6 = ""
    ipv6 = ""
    for line in proc.stdout:
        if line.find('brd ff:ff:ff:ff:ff:ff') != -1:
            mac = line.split()[1]
        if line.find('scope global temporary dynamic') != -1:
            temp_ipv6 = line.split()[1]
        if line.find('scope global dynamic') != -1:
            ipv6 = line.split()[1]

    proc.wait()
    assert temp_ipv6 != ipv6, 'IPV6 Address are similar!'
    temp_ipv6_end = temp_ipv6.split('/')[0].split(':')[-1]
    mac_end = mac.split(':')[-2]+mac.split(':')[-1]
    assert temp_ipv6_end != mac_end, 'Mac and tmp Ipv6 are similar in the end %s..%s'


@step(u'Hostname is visible in log "{log}"')
def hostname_visible(context, log):
    cmd = "grep $(hostname -s) %s" %log
    assert call(cmd, shell=True) == 0, 'Hostname was not visible in log'


@step(u'Hostname is not visible in log "{log}"')
def hostname_visible(context, log):
    cmd = "grep $(hostname -s) %s" %log
    assert call(cmd, shell=True) == 1, 'Hostname was visible in log'


@step(u'ifcfg-"{con_name}" file does not exist')
def ifcfg_doesnt_exist(context, con_name):
    cat = pexpect.spawn('cat /etc/sysconfig/network-scripts/ifcfg-%s' % con_name, logfile=context.log)
    assert cat.expect('No such file') == 0, 'Ifcfg-%s exists!' % con_name


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
        assert os.system('ping -c 1 -W 1 nix.cz') != 0
    if state == "is not":
        assert os.system('ping -c 1 -W 1 nix.cz') == 0


@step(u'Network trafic "{state}" dropped on "{device}"')
def network_dropped(context, state, device):
    if state == "is":
        assert os.system('ping -c 2 -I %s -W 1 10.11.5.19' % device) != 0
    if state == "is not":
        assert os.system('ping -c 2 -I %s -W 1 10.11.5.19' % device) == 0


@step(u'No error appeared in editor')
def no_error_appeared_in_editor(context):
    r = context.prompt.expect([pexpect.TIMEOUT, pexpect.EOF, 'Error'])
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
def note_print_property(context, pattern):
    assert re.search(pattern, context.noted) is not None, "Noted value does not match the pattern!"


@step(u'Note the output of "{command}" as value "{index}"')
def note_the_output_as(context, command, index):
    if not hasattr(context, 'noted'):
        context.noted = {}
    context.noted[index] = check_output(command, shell=True)


@step(u'Note the output of "{command}"')
def note_the_output_of(context, command):
    context.noted_value = check_output(command, shell=True)


@step(u'Open editor for connection "{con_name}"')
def open_editor_for_connection(context, con_name):
    prompt = pexpect.spawn('nmcli connection ed %s' % con_name, logfile=context.log)
    context.prompt = prompt
    r = prompt.expect(['Error', con_name])
    if r == 0:
        raise Exception('Got an Error while opening  %s profile %s' % (typ, con_name))


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
    while seconds > 0:
        ifconfig = pexpect.spawn(command, timeout = 180, logfile=context.log)
        if ifconfig.expect([pattern, pexpect.EOF]) == 0:
            return True
        seconds = seconds - 1
        sleep(1)
    raise Exception('Did not see the pattern %s in %d seconds' % (pattern, seconds))


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


@step(u'Ping {domain}')
def ping_domain(context, domain):
    ping = pexpect.spawn('ping -c 2 %s' %domain, logfile=context.log)
    ping.expect([pexpect.EOF])
    ping.close()
    assert ping.exitstatus == 0


@step(u'Ping6 {domain}')
def ping6_domain(context, domain):
    ping = pexpect.spawn('ping6 -c 2 %s' %domain, logfile=context.log)
    ping.expect([pexpect.EOF])
    ping.close()
    assert ping.exitstatus == 0


@step(u'Prepare connection')
def prepare_connection(context):
    context.execute_steps(u"""
        * Submit "set ipv4.method manual" in editor
        * Submit "set ipv4.addresses 1.2.3.4/24 1.1.1.1" in editor
        * Submit "set ipv4.never-default yes" in editor
        * Submit "set ipv6.method ignore" in editor
    """)


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
    os.system("sudo ip link set dev eth1 down")
    os.system("sudo ip link set dev eth2 down")
    os.system("sudo ip link set dev eth3 down")
    os.system("sudo ip link set dev eth4 down")
    os.system("sudo ip link set dev eth5 down")
    os.system("sudo ip link set dev eth6 down")
    os.system("sudo ip link set dev eth7 down")
    os.system("sudo ip link set dev eth8 down")
    os.system("sudo ip link set dev eth9 down")
    os.system("sudo ip link set dev eth10 down")
    os.system("nmcli device disconnect nm-bond")
    os.system("nmcli device disconnect nm-team")
    sleep(2)
    assert call("sudo service NetworkManager restart", shell=True) == 0
    sleep(4)


@step(u'Restart NM')
def restart_NM(context):
    sleep(1)
    call("service NetworkManager restart", shell=True) == 0
    sleep(4)


@step(u'Run child "{command}"')
def run_child_process(context, command):
    Popen(command, shell=True)


@step(u'Save in editor')
def save_in_editor(context):
    context.prompt.sendline('save')


@step(u'See Error while saving in editor')
def check_error_while_saving_in_editor(context):
    context.prompt.expect("Error")


@step(u'Set a property named "{name}" to "{value}" in editor')
def set_property_in_editor(context, name, value):
    if value == 'noted-value':
        context.prompt.sendline('set %s %s' % (name,context.noted))
    else:
        context.prompt.sendline('set %s %s' % (name,value))


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


@step(u'Spawn process "{command}"')
def spawn_process(context, command):
    if not hasattr(context, 'spawned_processes'):
        context.spawned_processes = {}
    context.spawned_processes[command] = pexpect.spawn(command, logfile=context.log)


@step(u'Start generic connection "{connection}" for "{device}"')
def start_generic_connection(context, connection, device):
    cli = pexpect.spawn('nmcli connection up %s ifname %s' % (connection, device), timeout = 180, logfile=context.log)
    r = cli.expect([pexpect.EOF, pexpect.TIMEOUT])
    if r == 1:
        raise Exception('nmcli connection up %s timed out (180s)' % connection)
    sleep(4)


@step(u'Start tailing file "{archivo}"')
def start_tailing(context, archivo):
    context.tail = pexpect.spawn('sudo tail -f %s' % archivo, timeout = 180, logfile=context.log)


@step(u'Team "{team}" is down')
def team_is_down(context, team):
    cmd = pexpect.spawn('teamdctl %s state dump' %team, logfile=context.log)
    print os.system('teamdctl %s state dump' %team)
    assert os.system('teamdctl %s state dump' %team) != 0, 'team "%s" exists' % (team)


@step(u'Terminate spawned process "{command}"')
def terminate_spawned_process(context, command):
    assert context.spawned_processes[command].terminate() == True


@step(u'Unable to ping {domain}')
def cannot_ping_domain(context, domain):
    ping = pexpect.spawn('ping -c 2 %s' %domain, logfile=context.log)
    ping.expect([pexpect.EOF])
    ping.close()
    assert ping.exitstatus != 0


@step(u'Unable to ping6 {domain}')
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


@step(u'Wait for at least "{secs}" seconds')
def wait_for_x_seconds(context,secs):
    sleep(int(secs))
    assert True


@step(u'Wrong bond options message shown in editor')
def wrong_bond_options_in_editor(context):
    context.prompt.expect("Error: failed to set 'options' property:")

