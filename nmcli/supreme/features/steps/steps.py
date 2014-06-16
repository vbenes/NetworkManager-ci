# -*- coding: UTF-8 -*-
from behave import step
from time import sleep
import pexpect
import exceptions
import os
import re
from subprocess import check_output, Popen

@step(u'Open editor for connection "{con_name}"')
def open_editor_for_connection(context, con_name):
    prompt = pexpect.spawn('nmcli connection ed %s' % con_name, timeout = 5, logfile=context.log)
    context.prompt = prompt


@step(u'Open editor for a type "{typ}"')
def open_editor_for_a_type(context, typ):
    prompt = pexpect.spawn('nmcli connection ed type %s' % typ, timeout = 5, logfile=context.log)
    context.prompt = prompt


@step(u'Open interactive connection addition mode for a type "{typ}"')
def open_interactive_for_a_type(context, typ):
    prompt = pexpect.spawn('nmcli -a connection add type %s' % typ, timeout = 5, logfile=context.log)
    context.prompt = prompt


@step(u'Open interactive connection addition mode')
def open_interactive(context):
    prompt = pexpect.spawn('nmcli -a connection add', timeout = 5, logfile=context.log)
    context.prompt = prompt


@step(u'Set a property named "{name}" to "{value}" in editor')
def set_property_in_editor(context, name, value):
    if value == 'noted-value':
        context.prompt.sendline('set %s %s' % (name,context.noted))
    else:
        context.prompt.sendline('set %s %s' % (name,value))


@step(u'Check value saved message showed in editor')
def check_saved_in_editor(context):
    context.prompt.expect('successfully')


@step(u'Save in editor')
def save_in_editor(context):
    context.prompt.sendline('save')


@step(u'Expect "{what}"')
def expect(context, what):
    context.prompt.expect(what)


@step(u'Submit "{what}"')
def submit(context, what):
    if what == 'noted-value':
        context.prompt.sendline(context.noted)
    elif what == '<enter>':
        context.prompt.send("\n")
    else:
        context.prompt.sendline(what)


@step(u'Print in editor')
def print_in_editor(context):
    context.prompt.sendline('print')


@step(u'Note the "{prop}" property from editor print output')
def note_print_property(context, prop):
    category, item = prop.split('.')
    context.prompt.sendline('print %s' % category)
    context.prompt.expect('%s.%s:\s+(\S+)' % (category, item))
    context.noted = context.prompt.match.group(1)
    print context.noted


@step(u'Check ifcfg-name file created with noted connection name')
def check_ifcfg_exists(context):
    cat = pexpect.spawn('cat /etc/sysconfig/network-scripts/ifcfg-%s' % context.noted, logfile=context.log)
    cat.expect('NAME=%s' % context.noted)


@step(u'Check ifcfg-name file created for connection "{con_name}"')
def check_ifcfg_exists_given_device(context, con_name):
    cat = pexpect.spawn('cat /etc/sysconfig/network-scripts/ifcfg-%s' % con_name, logfile=context.log)
    cat.expect('NAME=%s' % con_name)


@step(u'Quit editor')
def quit_editor(context):
    context.prompt.sendline('quit')


@step(u'Prompt is not running')
def prompt_is_not_running(context):
    sleep(1)
    assert context.prompt.isalive() is False


@step(u'Add a new connection of type "{typ}" ifname "{ifname}" and options "{options}"')
def add_new_default_connection(context, typ, ifname, options):
    pass


@step(u'Add a new connection of type "{typ}" and options "{options}"')
def add_new_default_connection_without_ifname(context, typ, options):
    cli = pexpect.spawn('nmcli connection add type %s %s' % (typ, options), logfile=context.log)
    if cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF]) == 0:
        raise Exception('Got an Error while creating connection of type %s with options %s' % (typ,options))


@step(u'Delete connection "{connection}"')
def delete_connection(context,connection):
    cli = pexpect.spawn('nmcli connection delete %s' % connection, timeout = 95, logfile=context.log)
    res = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if res == 0:
        raise Exception('Got an Error while deleting connection %s' % connection)
    elif res == 1:
        raise Exception('Deleting connecion %s timed out (95s)' % connection)


@step(u'Wait for at least "{secs}" seconds')
def wait_for_x_seconds(context,secs):
    sleep(int(secs))
    assert True


@step(u'"{pattern}" is visible with command "{command}"')
def check_pattern_visible_with_command(context, pattern, command):
    sleep(3) # time for all to get set
    ifconfig = pexpect.spawn(command, timeout = 180, logfile=context.log)
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
    sleep(3) # time for all to get set
    ifconfig = pexpect.spawn(command, timeout = 180, logfile=context.log)
    assert ifconfig.expect([pattern, pexpect.EOF]) == 1, 'pattern %s still visible with %s' % (pattern, command)


@step(u'ifcfg-"{con_name}" file does not exist')
def ifcfg_doesnt_exist(context, con_name):
    cat = pexpect.spawn('cat /etc/sysconfig/network-scripts/ifcfg-%s' % con_name, logfile=context.log)
    assert cat.expect('No such file') == 0, 'Ifcfg-%s exists!' % con_name


@step(u'Bring up connection "{connection}"')
def bring_up_connection(context, connection):
    cli = pexpect.spawn('nmcli connection up %s' % connection, timeout = 180, logfile=context.log)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while upping connection %s' % connection)
    elif r == 1:
        raise Exception('nmcli connection up %s timed out (180s)' % connection)


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


@step(u'Bring up connection "{connection}" ignoring error')
def bring_up_connection_ignore_error(context, connection):
    cli = pexpect.spawn('nmcli connection up %s' % connection, timeout = 180, logfile=context.log)
    r = cli.expect([pexpect.EOF, pexpect.TIMEOUT])
    if r == 1:
        raise Exception('nmcli connection up %s timed out (180s)' % connection)


@step(u'Bring down connection "{connection}"')
def bring_down_connection(context, connection):
    cli = pexpect.spawn('nmcli connection down %s' % connection, timeout = 180, logfile=context.log)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while downing a connection %s' % connection)
    elif r == 1:
        raise Exception('nmcli connection down %s timed out (180s)' % connection)


@step(u'Disconnect device "{device}"')
def disconnect_device(context, device):
    cli = pexpect.spawn('nmcli device dis %s' % device, timeout = 180, logfile=context.log)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while disconnecting a device %s' % device)
    elif r == 1:
        raise Exception('nmcli device disconnect %s timed out (180s)' % device)


@step(u'Connect device "{device}"')
def connect_device(context, device):
    cli = pexpect.spawn('nmcli device con %s' % device, timeout = 180, logfile=context.log)
    r = cli.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 0:
        raise Exception('Got an Error while connecting a device %s' % device)
    elif r == 1:
        raise Exception('nmcli device connect %s timed out (180s)' % device)


@step(u'Check "{options}" are present in describe output for object "{obj}"')
def check_describe_output_in_editor(context, options, obj):
    options = options.split('|')
    context.prompt.sendline('describe %s' % obj)
    for opt in options:
        assert context.prompt.expect(["%s" % opt, pexpect.TIMEOUT], timeout=5) == 0 , "Option %s was not described!" % opt


@step(u'Spawn process "{command}"')
def spawn_process(context, command):
    if not hasattr(context, 'spawned_processes'):
        context.spawned_processes = {}
    context.spawned_processes[command] = pexpect.spawn(command, logfile=context.log)


@step(u'Terminate spawned process "{command}"')
def terminate_spawned_process(context, command):
    assert context.spawned_processes[command].terminate() == True


@step(u'Execute "{command}"')
def execute_command(context, command):
    os.system(command)


@step(u'Execute "{command}" without waiting for process to finish')
def execute_command(context, command):
    Popen(command, shell=True)


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


@step(u'{action} all "{what}" devices')
def do_device_stuff(context, action, what):
    os.system("for dev in $(nmcli device status | grep '%s' | awk {'print $1'}); do nmcli device %s $dev; done" % (what, action))


@step(u'Check noted values "{i1}" and "{i2}" are the same')
def check_same_noted_values(context, i1, i2):
    assert context.noted[i1].strip() == context.noted[i2].strip(), "Noted values do not match!"


@step(u'Check noted output contains "{pattern}"')
def check_noted_output_contains(context, pattern):
    assert re.search(pattern, context.noted_value) is not None, "Noted output does not contain the pattern %s" % pattern


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


@step(u'See Error while saving in editor')
def check_error_while_saving_in_editor(context):
    context.prompt.expect("Error")


@step(u'No error appeared in editor')
def no_error_appeared_in_editor(context):
    r = context.prompt.expect([pexpect.TIMEOUT, pexpect.EOF, 'Error'])
    if r == 2:
        raise Exception('Got an Error in editor')


@step(u'Error appeared in editor')
def error_appeared_in_editor(context):
    r = context.prompt.expect(['Error', pexpect.TIMEOUT, pexpect.EOF])
    if r == 2 or r == 1:
        raise Exception('Did not see an Error in editor')


@step(u'"{value}" appeared in editor')
def value_appeared_in_editor(context, value):
    r = context.prompt.expect([value, pexpect.TIMEOUT, pexpect.EOF])
    if r == 2 or r == 1:
        raise Exception('Did not see "%s" in editor' % value)


@step(u'Change NM profile plugin to keyfile')
def change_to_keyfile(context):
    os.system("sudo sh -c \"echo '[main]\nplugins=keyfile' > /etc/NetworkManager/NetworkManager.conf\" ")


@step(u'Change NM profile plugin to ifcfg-rh')
def change_to_keyfile(context):
    os.system("sudo sh -c \"echo '[main]\nplugins=ifcfg-rh' > /etc/NetworkManager/NetworkManager.conf\" ")


@step(u'Start tailing file "{archivo}"')
def start_tailing(context, archivo):
    context.tail = pexpect.spawn('sudo tail -f %s' % archivo, timeout = 180, logfile=context.log)


@step(u'Look for "{content}" in tailed file')
def find_tailing(context, content):
    if context.tail.expect([content, pexpect.TIMEOUT, pexpect.EOF]) == 1:
        raise Exception('Did not see the "%s" in tail output before timeout (180s)' % content)
