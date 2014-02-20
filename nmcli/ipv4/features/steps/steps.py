# -*- coding: UTF-8 -*-
from behave import step
from time import sleep, time
import pexpect
import os
from subprocess import check_output, Popen


@step(u'Open editor for connection "{con_name}"')
def open_editor_for_connection(context, con_name):
    prompt = pexpect.spawn('nmcli connection ed %s' % con_name, logfile=context.log)
    context.prompt = prompt
    r = prompt.expect(['Error', con_name])
    if r == 0:
        raise Exception('Got an Error while opening  %s profile %s' % (typ, con_name))


@step(u'Add connection for a type "{typ}" named "{name}" for device "{ifname}"')
def add_connection(context, typ, name, ifname):
    cli = pexpect.spawn('nmcli connection add type %s con-name %s ifname %s' % (typ, name, ifname), logfile=context.log)
    r = cli.expect(['Error', pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while adding %s connection %s for device %s' % (typ, name, ifname))
    #sleep(2)


@step(u'Disconnect device "{name}"')
def disconnect_connection(context, name):
    cli = pexpect.spawn('nmcli device disconnect %s' % name, logfile=context.log,  timeout=180)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while disconnecting device %s' % name)
    elif r == 1:
        raise Exception('nmcli disconnect %s timed out (180s)' % name)
    sleep(1)


@step(u'Bring "{action}" connection "{name}"')
def start_stop_connection(context, action, name):
    if action == "down":
        if os.system("nmcli connection show active |grep %s" %name) != 0:
            print "Warning: Connection is down no need to down it again"
            return
    cli = pexpect.spawn('nmcli connection %s id %s' % (action, name), logfile=context.log,  timeout=180)
    r = cli.expect(['Error', 'Timeout', pexpect.TIMEOUT, pexpect.EOF])
    sleep(5)
    if r == 0:
        raise Exception('Got an Error while %sing connection %s' % (action, name))
    elif r == 1:
        raise Exception('nmcli connection %s %s timed out (90s)' % (action, name))
    elif r == 2:
        raise Exception('nmcli connection %s %s timed out (180s)' % (action, name))


@step(u'Bring up connection "{connection}" ignoring error')
def bring_up_connection_ignore_error(context, connection):
    cli = pexpect.spawn('nmcli connection up %s' % connection, timeout = 180, logfile=context.log)
    r = cli.expect([pexpect.EOF, pexpect.TIMEOUT])
    if r == 1:
        raise Exception('nmcli connection up %s timed out (180s)' % connection)


@step(u'Delete connection "{name}"')
def delete_connection(context, name):
    cli = pexpect.spawn('nmcli connection delete %s' % name, logfile=context.log)
    if cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF]) == 0:
        raise Exception('Got an Error while deleting connection %s' % name)
    sleep(2)


#@step(u'Open editor for a type "{typ}"')
#def open_editor_for_a_type(context, typ):
#    prompt = pexpect.spawn('nmcli connection edit type %s' % (typ), logfile=context.log)
#    context.prompt = prompt


@step(u'Set a property named "{name}" to "{value}" in editor')
def set_property_in_editor(context, name, value):
    context.prompt.sendline('set %s %s' % (name,value))


@step(u'Save in editor')
def save_in_editor(context):
    context.prompt.sendline('save')


@step(u'Submit "{command}" in editor')
def submit_in_editor(context, command):
    context.prompt.sendline('%s' % command)


@step(u'Enter in editor')
def enter_in_editor(context):
    context.prompt.sendline('\n')


@step(u'Quit editor')
def quit_editor(context):
    context.prompt.sendline('quit')


@step(u'Restart NM')
def restart_NM(context):
    os.system("service NetworkManager restart")
    sleep(5)


@step(u'Check "{options}" are present in describe output for object "{obj}"')
def check_describe_output_in_editor(context, options, obj):
    options = options.split('|')
    context.prompt.sendline('describe %s' % obj)
    for opt in options:
        assert context.prompt.expect(["%s" % opt, pexpect.TIMEOUT], timeout=5) == 0 , "Option %s was not described!" % opt


@step(u'Prompt is not running')
def prompt_is_not_running(context):
    sleep(1)
    assert context.prompt.isalive() is False


@step(u'Check if object item "{item}" has value "{value}" via print')
def value_printed(context, item, value):
    context.prompt.sendline('print')
    #sleep(2)
    if value == "current_time":
        t_int = int(time())
        t_str = str(t_int)
        value = t_str[:-2]
        print value

    context.prompt.expect('%s\s+%s' %(item, value))
    print context.prompt


@step(u'Value saved message showed in editor')
def check_saved_in_editor(context):
    context.prompt.expect('successfully')


#@step(u'Error type "{type}" shown in editor')
#def check_error_in_editor(context, type):
#    context.prompt.expect("Error: failed to set '%s' property" % type)

@step(u'Spawn process "{command}"')
def spawn_process(context, command):
    if not hasattr(context, 'spawned_processes'):
        context.spawned_processes = {}
    context.spawned_processes[command] = pexpect.spawn(command, logfile=context.log)

@step(u'Run child "{command}"')
def run_child_process(context, command):
    Popen(command, shell=True)

@step(u'Note the output of "{command}" as value "{index}"')
def note_the_output_as(context, command, index):
    if not hasattr(context, 'noted'):
        context.noted = {}
    context.noted[index] = check_output(command, shell=True)


@step(u'Note the output of "{command}"')
def note_the_output_of(context, command):
    context.noted_value = check_output(command, shell=True)


@step(u'Check noted values "{i1}" and "{i2}" are the same')
def check_same_noted_values(context, i1, i2):
    assert context.noted[i1].strip() == context.noted[i2].strip(), "Noted values do not match!"


@step(u'Terminate spawned process "{command}"')
def terminate_spawned_process(context, command):
    assert context.spawned_processes[command].terminate() == True


@step(u'Error type "{type}" while saving in editor')
def check_error_while_saving_in_editor(context, type):
    context.prompt.expect("Error: %s" % type)


@step(u'Check if "{name}" is active connection')
def is_active_connection(context, name):
    cli = pexpect.spawn('nmcli -t -f NAME connection show active', logfile=context.log)
    r = cli.expect([name,pexpect.EOF])
    if r == 1:
        raise Exception('Connection %s is not active' % name)

@step(u'"{pattern}" is visible with command "{command}"')
def check_pattern_visible_with_command(context, pattern, command):
    sleep(1) # time for all to get set
    ifconfig = pexpect.spawn(command, maxread=20000, logfile=context.log)
    assert ifconfig.expect([pattern, pexpect.EOF]) == 0, 'pattern %s is not visible with %s' % (pattern, command)


@step(u'"{pattern}" is not visible with command "{command}"')
def check_pattern_not_visible_with_command(context, pattern, command):
    sleep(1) # time for all to get set
    ifconfig = pexpect.spawn(command, maxread=20000, logfile=context.log)
    assert ifconfig.expect([pattern, pexpect.EOF]) != 0, 'pattern %s still visible with %s' % (pattern, command)


@step(u'Check if "{name}" is not active connection')
def is_nonactive_connection(context, name):
    cli = pexpect.spawn('nmcli -t -f NAME connection show active', logfile=context.log)
    r = cli.expect([name,pexpect.EOF])
    if r == 0:
        raise Exception('Connection %s is active' % name)


@step(u'Ping {domain}')
def ping_domain(context, domain):
    ping = pexpect.spawn('ping -c 2 %s' %domain, logfile=context.log)
    ping.expect([pexpect.EOF])
    ping.close()
    assert ping.exitstatus == 0



@step(u'Unable to ping {domain}')
def cannot_ping_domain(context, domain):
    ping = pexpect.spawn('ping -c 2 %s' %domain, logfile=context.log)
    ping.expect([pexpect.EOF])
    ping.close()
    assert ping.exitstatus != 0


@step(u'Network trafic "{state}" dropped')
def network_dropped(context, state):
    if state == "is":
        assert os.system('ping -c 1 -W 1 nix.cz') != 0
    if state == "is not":
        assert os.system('ping -c 1 -W 1 nix.cz') == 0
