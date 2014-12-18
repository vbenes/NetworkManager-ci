import dbus
import IPy
import uuid

def ip_to_str(ip):
    return '.'.join(reversed(str(IPy.IP(ip)).split('.')))

def print_ipv4(setting):
    for address in setting["ipv4"]["addresses"]:
        print ip_to_str(address[0]), address[1], ip_to_str(address[2])

bus = dbus.SystemBus()

o = bus.get_object('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager/Settings')
s = dbus.Dictionary({
    'connection': {
        'id': 'ethos',
        'uuid': str(uuid.uuid1()),
        'interface-name': 'nonexistant',
        'type': '802-3-ethernet',
    },
    'ipv4': {
        'addresses': dbus.Array([
            [16885952, 24, 0]
        ], signature='au'),
        'method': 'manual'
    },
    '802-3-ethernet': {
    }
}, signature='sa{sv}')
object_path = o.AddConnection(s, dbus_interface='org.freedesktop.NetworkManager.Settings')

o = bus.get_object('org.freedesktop.NetworkManager', object_path)

setting = o.GetSettings(dbus_interface='org.freedesktop.NetworkManager.Settings.Connection')

print "Original state: 1 address without gateway"
print_ipv4(setting)
print

setting["ipv4"]["addresses"].append([16885952, 24, 1677830336])

print "Updating: add address with gateway"
print_ipv4(setting)
print
o.Update(setting)

