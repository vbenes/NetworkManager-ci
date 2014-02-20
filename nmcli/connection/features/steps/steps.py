# -*- coding: UTF-8 -*-
from behave import step
from time import sleep, time
import pexpect
import os
from subprocess import Popen

@step(u'Open editor for connection "{con_name}"')
def open_editor_for_connection(context, con_name):
    prompt = pexpect.spawn('nmcli connection ed %s' % con_name, logfile=context.log, maxread=6000)
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


@step(u'Open editor for "{con_name}" with timeout')
def open_editor_for_connection_with_timeout(context, con_name):
    prompt = pexpect.spawn('nmcli connection ed %s' % (con_name), logfile=context.log, maxread=6000, timeout=5)
    sleep(2)
    context.prompt = prompt
    r = prompt.expect(['Error', con_name])
    if r == 0:
        raise Exception('Got an Error while opening profile %s' % (con_name))


@step(u'Delete connection "{name}" and hit enter')
def delete_connection_with_enter(context, name):

    os.system('nmcli connection delete id %s' %name)
    sleep(5)

    context.prompt.sendline('\n')
    sleep(2)

    assert context.prompt.isalive() is True, 'Something went wrong'

@step(u'Autoconnect warning is shown')
def autoconnect_warning(context):
    r = context.prompt.expect(["Saving the connection with \'autoconnect=yes\'. That might result in an immediate activation of the connection.\s+Do you still want to save?", "successfully"])
    if r != 0:
        raise Exception('Autoconnect warning was not shown')


@step(u'Add connection for a type "{typ}" named "{name}" for device "{ifname}"')
def add_connection(context, typ, name, ifname):
    cli = pexpect.spawn('nmcli connection add type %s con-name %s ifname %s' % (typ, name, ifname), logfile=context.log)
    r = cli.expect(['Error', pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while adding %s connection %s for device %s' % (typ, name, ifname))
    sleep(1)


@step(u'Reboot')
def reboot(context):
    os.system("ip link set dev eth1 down")
    os.system("ip link set dev eth2 down")
    os.system("ip link set dev eth3 down")
    os.system("ip link set dev eth4 down")
    os.system("ip link set dev eth5 down")
    os.system("ip link set dev eth6 down")
    os.system("ip link set dev eth7 down")
    os.system("ip link set dev eth8 down")
    os.system("ip link set dev eth9 down")
    os.system("ip link set dev eth10 down")
    sleep(2)
    os.system("sudo service NetworkManager restart")
    sleep(10)


@step(u'Disconnect device "{name}"')
def disconnect_connection(context, name):
    cli = pexpect.spawn('nmcli device disconnect %s' % name, logfile=context.log,  timeout=180)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while disconnecting device %s' % name)
    elif r == 1:
        raise Exception('nmcli disconnect %s timed out (180s)' % name)
    sleep(2)


@step(u'Bring "{action}" connection "{name}"')
def start_stop_connection(context, action, name):
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
    cli = pexpect.spawn('nmcli connection delete %s' % name, logfile=context.log)
    if cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF]) == 0:
        raise Exception('Got an Error while deleting connection %s' % name)
    sleep(2)


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
    context.prompt.close(force=True)


@step(u'Restart NM')
def restart_NM(context):
    os.system("service NetworkManager restart")
    sleep(10)


@step(u'Check "{options}" are present in describe output for object "{obj}"')
def check_describe_output_in_editor(context, options, obj):
    options = options.split('|')
    context.prompt.sendline('describe %s' % obj)
    for opt in options:
        assert context.prompt.expect(["%s" % opt, pexpect.TIMEOUT], timeout=5) == 0 , "Option %s was not described!" % opt


@step(u'"{pattern}" is visible with command "{command}"')
def check_pattern_visible_with_command(context, pattern, command):
    exp = pexpect.spawn(command, logfile=context.log)
    assert exp.expect([pattern, pexpect.EOF]) == 0, 'pattern %s is not visible with "%s"' % (pattern, command)


@step(u'"{pattern}" is not visible with command "{command}"')
def check_pattern_is_not_visible_with_command(context, pattern, command):
    exp = pexpect.spawn(command, logfile=context.log)
    assert exp.expect([pattern, pexpect.EOF]) != 0, 'pattern %s is visible with "%s"' % (pattern, command)


@step(u'"{pattern}" is visible with tab after "{command}"')
def check_pattern_visible_with_tab_after_command(context, pattern, command):
    exp = pexpect.spawn('/bin/bash', logfile=context.log)
    exp.send(command)
    exp.sendcontrol('i')
    exp.sendcontrol('i')
    exp.sendcontrol('i')
    exp.sendeof()

    assert exp.expect([pattern, pexpect.EOF]) == 0, 'pattern %s is not visible with "%s"' % (pattern, command)


@step(u'Run child "{command}"')
def run_child_process(context, command):
    command = "sudo "+ command
    Popen(command, shell=True)
    Popen("sleep 3", shell=True).wait()


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
    sleep(1)


@step(u'Value saved message showed in editor')
def check_saved_in_editor(context):
    context.prompt.expect('successfully')


@step(u'Error type "{type}" shown in editor')
def check_error_in_editor(context, type):
    context.prompt.expect("Error: failed to set '%s' property" % type)

@step(u'Error type "{type}" while saving in editor')
def check_error_while_saving_in_editor(context, type):
    context.prompt.expect("Error: Failed to save '%s'" % type)

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

@step(u'Network trafic "{state}" dropped on "{device}"')
def network_dropped(context, state, device):
    if state == "is":
        assert os.system('ping -c 2 -I %s -W 1 10.11.5.19' % device) != 0
    if state == "is not":
        assert os.system('ping -c 2 -I %s -W 1 10.11.5.19' % device) == 0
