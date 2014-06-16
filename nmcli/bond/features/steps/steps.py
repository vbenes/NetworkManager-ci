# -*- coding: UTF-8 -*-
from behave import step
from time import sleep
import pexpect
import os


@step(u'Open wizard for adding new connection')
def add_novice_connection(context):
    prompt = pexpect.spawn("nmcli -a connection add", logfile=context.log)
    context.prompt = prompt
    #sleep(2)


@step(u'Expect "{what}"')
def expect(context, what):
    context.prompt.expect(what)


@step(u'Open editor for connection "{con_name}"')
def open_editor_for_connection(context, con_name):
    prompt = pexpect.spawn('nmcli connection ed %s' % con_name, logfile=context.log)
    context.prompt = prompt

@step(u'Activate connection')
def activate_connection(context):
    prompt = pexpect.spawn('activate')
    context.prompt = prompt

@step(u'Add connection for a type "{typ}" named "{name}"')
def add_connection(context, typ, name):
    cli = pexpect.spawn('nmcli connection add type %s con-name %s' % (typ, name), logfile=context.log)
    r = cli.expect(['Error', pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while adding %s connection %s' % (typ, name))
    sleep(1)


@step(u'Add connection type "{typ}" named "{name}" for device "{ifname}"')
def add_connection_for_iface(context, typ, name, ifname):
    cli = pexpect.spawn('nmcli connection add type %s con-name %s ifname %s' % (typ, name, ifname), logfile=context.log)
    r = cli.expect(['Error', pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while adding %s connection %s for device %s' % (typ, name, ifname))
    sleep(1)


@step(u'Bring up connection "{connection}" ignoring error')
def bring_up_connection_ignore_error(context, connection):
    cli = pexpect.spawn('nmcli connection up %s' % connection, timeout = 180, logfile=context.log)
    r = cli.expect([pexpect.EOF, pexpect.TIMEOUT])
    if r == 1:
        raise Exception('nmcli connection up %s timed out (180s)' % connection)


@step(u'Add slave connection for master "{master}" on device "{device}" named "{name}"')
def open_slave_connection(context, master, device, name):
    cli = pexpect.spawn('nmcli connection add type bond-slave ifname %s con-name %s master %s' % (device, name, master), logfile=context.log)
    r = cli.expect(['Error', pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while adding slave connection %s on device %s for master %s' % (name, device, master))
    sleep(2)


@step(u'Disconnect device "{name}"')
def disconnect_connection(context, name):
    cli = pexpect.spawn('nmcli device disconnect %s' % name, logfile=context.log,  timeout=180)
    sleep(3)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while disconnecting device %s' % name)
    elif r == 1:
        raise Exception('nmcli disconnect %s timed out (180s)' % name)


@step(u'Bring "{action}" connection "{name}"')
def start_stop_connection(context, action, name):
    if action == "down":
        if os.system("nmcli connection show active |grep %s" %name) != 0:
            print "Warning: Connection is down no need to down it again"
            return
    cli = pexpect.spawn('nmcli connection %s id %s' % (action, name), logfile=context.log,  timeout=180)
    r = cli.expect(['Error', 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while %sing connection %s' % (action, name))
    elif r == 1:
        raise Exception('nmcli connection %s %s timed out (90s)' % (action, name))
    elif r == 2:
        raise Exception('nmcli connection %s %s timed out (180s)' % (action, name))
    sleep(2)


@step(u'Delete connection "{name}"')
def delete_connection(context, name):
    cli = pexpect.spawn('nmcli connection delete id %s' % name, logfile=context.log)
    if cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF]) == 0:
        raise Exception('Got an Error while deleting connection %s' % name)
    sleep(2)


@step(u'Open editor for a type "{typ}"')
def open_editor_for_a_type(context, typ):
    prompt = pexpect.spawn('nmcli connection edit type %s con-name %s0' % (typ, typ), logfile=context.log)
    context.prompt = prompt


@step(u'Set a property named "{name}" to "{value}" in editor')
def set_property_in_editor(context, name, value):
    context.prompt.sendline('set %s %s' % (name,value))


@step(u'Save in editor')
def save_in_editor(context):
    context.prompt.sendline('save')

@step(u'Submit "{command}" in editor')
def submit_in_editor(context, command):
    context.prompt.sendline(command)


@step(u'Print in editor')
def print_in_editor(context):
    context.prompt.sendline('print')


@step(u'Enter in editor')
def enter_in_editor(context):
    context.prompt.send('\n')


@step(u'Quit editor')
def quit_editor(context):
    context.prompt.sendline('quit')


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
    sleep(2)
    os.system("sudo service NetworkManager restart")
    sleep(10)


@step(u'Restart NM')
def restart_NM(context):
    os.system("init 2; init 3")
    #os.system("sudo service NetworkManager restart")
    sleep(10)


@step(u'Check "{options}" are present in describe output for object "{obj}"')
def check_describe_output_in_editor(context, options, obj):
    options = options.split('|')
    context.prompt.sendline('describe %s' % obj)
    for opt in options:
        assert context.prompt.expect(["%s" % opt, pexpect.TIMEOUT], timeout=5) == 0 , "Option %s was not described!" % opt


@step(u'"{pattern}" is visible with command "{command}"')
def check_pattern_visible_with_command(context, pattern, command):
    cmd = pexpect.spawn(command, logfile=context.log)
    assert cmd.expect([pattern, pexpect.EOF]) == 0, 'pattern %s is not visible with "%s"' % (pattern, command)


@step(u'Prompt is not running')
def prompt_is_not_running(context):
    sleep(1)
    assert context.prompt.isalive() is False


@step(u'Value saved message showed in editor')
def check_saved_in_editor(context):
    context.prompt.expect('successfully')


@step(u'Mode missing message shown in editor')
def mode_missing_in_editor(context):
    context.prompt.expect("Error: connection verification failed: bond.options: mandatory option 'mode' is missing")


@step(u'Wrong bond options message shown in editor')
def wrong_bond_options_in_editor(context):
    context.prompt.expect("Error: failed to set 'options' property:")


@step(u'Check bond "{bond}" in proc')
def check_bond_in_proc(context, bond):
    child = pexpect.spawn('cat /proc/net/bonding/%s ' % (bond) , logfile=context.log)
    assert child.expect(['Ethernet Channel Bonding Driver', pexpect.EOF]) == 0; "%s is not in proc" % bond


@step(u'Check slave "{slave}" in bond "{bond}" in proc')
def check_slave_in_bond_in_proc(context, slave, bond):
    child = pexpect.spawn('cat /proc/net/bonding/%s' % (bond), logfile=context.log )
    assert child.expect(["Slave Interface: %s\s+MII Status: up" % slave, pexpect.EOF]) == 0, "Slave %s is not in %s" % (slave, bond)


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


