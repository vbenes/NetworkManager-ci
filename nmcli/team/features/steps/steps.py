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
    cli = pexpect.spawn('nmcli connection add type team-slave ifname %s con-name %s master %s' % (device, name, master), logfile=context.log)
    r = cli.expect(['Error', pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while adding slave connection %s on device %s for master %s' % (name, device, master))
    sleep(1)


@step(u'Disconnect device "{name}"')
def disconnect_connection(context, name):
    cli = pexpect.spawn('nmcli device disconnect %s' % name, logfile=context.log,  timeout=180)
    sleep(2)
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


@step(u'Submit \'{command}\' in editor')
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


@step(u'Restart NM')
def restart_NM(context):
    os.system("sudo service NetworkManager restart")
    sleep(10)


@step(u'Reboot')
def reboot(context):
    os.system("ip link set dev eth1 down")
    os.system("ip link set dev eth2 down")
    os.system("nmcli device disconnect nm-team")
    sleep(2)
    os.system("sudo service NetworkManager restart")
    #if os.system("nmcli connection show configured team0 |grep autoconnect |grep yes ") == 0:
    #    os.system("nmcli con up team0")
    #if os.system("nmcli connection show configured team0.1 |grep autoconnect |grep yes ") == 0:
    #    os.system("nmcli con up team0")
    #    os.system("nmcli con up team0.1")    
    #    if os.system("nmcli connection show configured team0.2 |grep autoconnect |grep yes ") == 0:
    #        os.system("nmcli con up team0.1")    
    sleep(2)    


@step(u'Check "{options}" are present in describe output for object "{obj}"')
def check_describe_output_in_editor(context, options, obj):
    options = options.split('|')
    context.prompt.sendline('describe %s' % obj)
    for opt in options:
        assert context.prompt.expect(["%s" % opt, pexpect.TIMEOUT], timeout=5) == 0 , "Option %s was not described!" % opt


@step(u'\'{pattern}\' is visible with command \'{command}\'')
def check_pattern_visible_with_command(context, pattern, command):
    cmd = pexpect.spawn(command, logfile=context.log)
    assert cmd.expect([pattern, pexpect.EOF]) == 0, 'pattern %s is not visible with "%s"' % (pattern, command)

@step(u'\'{pattern}\' is not visible with command \'{command}\'')
def check_pattern_not_with_command(context, pattern, command):
    cmd = pexpect.spawn(command, logfile=context.log)
    assert cmd.expect([pattern, pexpect.EOF]) != 0, 'pattern %s is visible with "%s"' % (pattern, command)

@step(u'Team "{team}" is down')
def team_is_down(context, team):
    cmd = pexpect.spawn('teamdctl %s state dump' %team, logfile=context.log)
    print os.system('teamdctl %s state dump' %team)
    assert os.system('teamdctl %s state dump' %team) != 0, 'team "%s" exists' % (team)
    
@step(u'Prompt is not running')
def prompt_is_not_running(context):
    sleep(1)
    assert context.prompt.isalive() is False


@step(u'Value saved message showed in editor')
def check_saved_in_editor(context):
    context.prompt.expect('sucessfully saved')


@step(u'Mode missing message shown in editor')
def mode_missing_in_editor(context):
    context.prompt.expect("Error: connection verification failed: bond.options: mandatory option 'mode' is missing")


@step(u'Wrong bond options message shown in editor')
def wrong_bond_options_in_editor(context):
    context.prompt.expect("Error: failed to set 'options' property: 'modem' not among \[mode, miimon, downdelay, updelay, arp_interval, arp_ip_target\]")


@step(u'Check slave "{slave}" in team "{team}" is "{state}"')
def check_slave_in_team_is_up(context, slave, team, state):
    child = pexpect.spawn('sudo teamdctl %s state dump' % (team), logfile=context.log )
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
        

