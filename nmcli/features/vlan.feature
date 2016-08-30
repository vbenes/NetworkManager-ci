@testplan
Feature: nmcli - vlan

 # Background:
 #   * Close Evolution and cleanup data

    @cleanvlan
    Scenario: Clean vlan
    * "eth0" is visible with command "ifconfig"

    @vlan
    @testcase_281205
    Scenario: nmcli - vlan - add default device
     * Add a new connection of type "vlan" and options "con-name eth1.99 dev eth1 id 99"
     Then "eth1.99:" is visible with command "ifconfig"
     Then Check ifcfg-name file created for connection "eth1.99"


    @rhbz1273879
    @restart
    @vlan
    @nmcli_vlan_restart_persistence
    Scenario: nmcli - vlan - restart persistence
    * Execute "systemctl stop NetworkManager"
    * Append "NAME=eth0.99" to ifcfg file "eth0.99"
    * Append "ONBOOT=yes" to ifcfg file "eth0.99"
    * Append "BOOTPROTO=none" to ifcfg file "eth0.99"
    * Append "IPADDR=172.31.3.10" to ifcfg file "eth0.99"
    * Append "TYPE=Vlan" to ifcfg file "eth0.99"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth0.99"
    * Append "DEVICE=eth0.99" to ifcfg file "eth0.99"
    * Append "PHYSDEV=eth0" to ifcfg file "eth0.99"
    * Restart NM
    Then "eth0.99\s+vlan\s+connected" is visible with command "nmcli device" in "10" seconds
    * Restart NM
    Then "eth0.99\s+vlan\s+connected" is visible with command "nmcli device" in "10" seconds


    @vlan
    @testcase_281263
    Scenario: nmcli - vlan - remove connection
    Given "inet 10.42." is not visible with command "ifconfig"
    * Add a new connection of type "vlan" and options "con-name eth1.299 autoconnect no dev eth1 id 299"
    * Open editor for connection "eth1.299"
    * Set a property named "ipv4.method" to "shared" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "eth1.299"
    * "inet 10.42." is visible with command "ifconfig"
    * Delete connection "eth1.299"
    * Wait for at least "5" seconds
    Then "inet 10.42." is not visible with command "ifconfig"
    Then ifcfg-"eth1.299" file does not exist


    @vlan
    @testcase_281326
    Scenario: nmcli - vlan - connection up
    * Add a new connection of type "vlan" and options "con-name eth1.99 autoconnect no dev eth1 id 99"
    * Open editor for connection "eth1.99"
    * Set a property named "ipv4.method" to "shared" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * "eth1.99" is not visible with command "ifconfig"
    * Bring up connection "eth1.99"
    Then "eth1.99" is visible with command "ifconfig"


    @vlan
    @testcase_284356
    Scenario: nmcli - vlan - connection up while up
    * Add a new connection of type "vlan" and options "con-name eth1.99 autoconnect yes dev eth1 id 99"
    Then "eth1.99\s+vlan\s+connected" is visible with command "nmcli device" in "30" seconds
    * Open editor for connection "eth1.99"
    * Set a property named "ipv4.method" to "shared" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    # With no errors
    Then Bring up connection "eth1.99"


    @vlan
    @testcase_281271
    Scenario: nmcli - vlan - connection down
    * "inet 10.42." is not visible with command "ifconfig"
    * Add a new connection of type "vlan" and options "con-name eth1.399 autoconnect no dev eth1 id 399"
    * Open editor for connection "eth1.399"
    * Set a property named "ipv4.method" to "shared" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "eth1.399"
    * "inet 10.42." is visible with command "ifconfig"
    * Bring down connection "eth1.399"
    Then "inet 10.42." is not visible with command "ifconfig"

    @vlan
    @testcase_281264
    Scenario: nmcli - vlan - connection down (autoconnect on)
    * "inet 10.42." is not visible with command "ifconfig"
    * Add a new connection of type "vlan" and options "con-name eth1.399 autoconnect no dev eth1 id 399"
    * Open editor for connection "eth1.399"
    * Set a property named "connection.autoconnect" to "yes" in editor
    * Set a property named "ipv4.method" to "shared" in editor
    * Save in editor
    * Submit "yes" in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "eth1.399"
    * "inet 10.42." is visible with command "ifconfig"
    * Bring down connection "eth1.399"
    * Wait for at least "10" seconds
    Then "inet 10.42." is not visible with command "ifconfig"

    @vlan
    @testcase_281332
    Scenario: nmcli - vlan - change id without interface set
    * Add a new connection of type "vlan" and options "con-name eth1.65 autoconnect no dev eth1 id 65"
    * Open editor for connection "eth1.65"
    * Set a property named "ipv4.method" to "shared" in editor
    * Save in editor
    * Quit editor
    * Check value saved message showed in editor
    * Bring up connection "eth1.65"
    * "eth1.65@eth1" is visible with command "ip a"
    * Open editor for connection "eth1.65"
    * Set a property named "vlan.id" to "55" in editor
    * Save in editor
    * No error appeared in editor
    * Bring down connection "eth1.65"
    * Bring up connection "eth1.65"
    * "eth1.55@eth1" is visible with command "ip a"


    @vlan
    @testcase_281394
    Scenario: nmcli - vlan - change id
    * Add a new connection of type "vlan" and options "con-name eth1.165 autoconnect no dev eth1 id 165"
    * Open editor for connection "eth1.165"
    * Set a property named "ipv4.method" to "shared" in editor
    * No error appeared in editor
    * Save in editor
    * Quit editor
    * Check value saved message showed in editor
    * Bring up connection "eth1.165"
    * Bring down connection "eth1.165"
    * Open editor for connection "eth1.165"
    * Set a property named "vlan.id" to "265" in editor
    * Set a property named "vlan.interface-name" to "eth1.265" in editor
    * Set a property named "connection.id" to "eth1.265" in editor
    * Set a property named "connection.interface-name" to "eth1.265" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * "eth1.265:" is not visible with command "ifconfig"
    * "inet 10.42.0.1" is not visible with command "ifconfig"
    * Bring up connection "eth1.265"
    Then "eth1.265:" is visible with command "ifconfig"
    Then "inet 10.42.0.1" is visible with command "ifconfig"

    @vlan
    @testcase_284357
    Scenario: nmcli - vlan - describe all
    * Open editor for a type "vlan"
    Then Check "parent|id|flags|ingress-priority-map|egress-priority-map" are present in describe output for object "vlan"


    @rhbz1244048
    @vlan
    @assertion_failure
    Scenario: nmcli - vlan - assertion failure
    * Add a new connection of type "vlan" and options "con-name eth1.99 autoconnect no ifname eth1.101 dev eth1 id 99"
    * Open editor for connection "eth1.99"
    * Set a property named "vlan.flags" to "1" in editor
    * Save in editor
    * No error appeared in editor
    * Quit editor

    @vlan
    @testcase_281282
    Scenario: nmcli - vlan - describe separately
    * Open editor for a type "vlan"
    Then Check "\[parent\]" are present in describe output for object "vlan.parent"
    Then Check "\[id\]" are present in describe output for object "vlan.id"
    Then Check "\[flags\]" are present in describe output for object "vlan.flags"
    Then Check "\[ingress-priority-map\]" are present in describe output for object "vlan.ingress-priority-map"
    Then Check "\[egress-priority-map\]" are present in describe output for object "vlan.egress-priority-map"


    @vlan
    @testcase_284358
    Scenario: nmcli - vlan - disconnect device
    * "inet 10.42." is not visible with command "ifconfig"
    * Add a new connection of type "vlan" and options "con-name eth1.399 autoconnect no dev eth1 id 399"
    * Open editor for connection "eth1.399"
    * Set a property named "ipv4.method" to "shared" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "eth1.399"
    * "inet 10.42." is visible with command "ifconfig"
    * Disconnect device "eth1.399"
    Then "inet 10.42." is not visible with command "ifconfig"


    @vlan
    @testcase_284359
    Scenario: nmcli - vlan - disconnect device (with autoconnect)
    * "inet 10.42." is not visible with command "ifconfig"
    * Add a new connection of type "vlan" and options "con-name eth1.499 autoconnect no dev eth1 id 499"
    * Open editor for connection "eth1.499"
    * Set a property named "connection.autoconnect" to "yes" in editor
    * Set a property named "ipv4.method" to "shared" in editor
    * Save in editor
    * Submit "yes" in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "eth1.499"
    * "inet 10.42." is visible with command "ifconfig"
    * Disconnect device "eth1.499"
    Then "inet 10.42." is not visible with command "ifconfig"


    @vlan
    @testcase_281211
    Scenario: nmcli - vlan - device tagging
    * Execute "yum -y install wireshark"
    * Add a new connection of type "vlan" and options "con-name eth1.80 dev eth1 id 80"
    * "eth1.80:" is visible with command "ifconfig"
    * Spawn "ping -I eth1.80 8.8.8.8" command
    Then "ID: 80" is visible with command "tshark -i eth1 -T fields -e vlan"
    Then Terminate spawned process "ping -I eth1.80 8.8.8.8"


    @vlan
    @vlan_on_bridge
    Scenario: nmcli - vlan - on bridge
    * Add a new connection of type "bridge" and options "con-name bridge ifname bridge stp no"
    * Add a new connection of type "vlan" and options "con-name bridge.15 dev bridge id 15"
    Then "bridge.15:" is visible with command "ifconfig"


    @rhbz1276343
    @vlan @restart
    @vlan_not_duplicated
    Scenario: nmcli - vlan - do not duplicate mtu and ipv4 vlan
    * Add a new connection of type "vlan" and options "con-name vlan dev eth1 id 80"
    * Modify connection "vlan" changing options "eth.mtu 1450 ipv4.method manual ipv4.addresses 1.2.3.4/24"
    * Bring "up" connection "testeth1"
    * Bring "up" connection "vlan"
    * Restart NM
    Then "eth1.80:connected:vlan" is visible with command "nmcli -t -f DEVICE,STATE,CONNECTION device" in "20" seconds


    @rhbz1264322
    @vlan_update_mac_from_bond
    Scenario: nmcli - vlan - update mac address from bond
    # Setup given in the bug description
    * Add a new connection of type "bridge" and options "ifname br0 con-name bridge-br0 autoconnect no"
    * Modify connection "bridge-br0" changing options "bridge.stp no connection.autoconnect yes"
    * Modify connection "bridge-br0" changing options "ipv4.method manual ipv4.address '192.168.1.11/24' ipv4.gateway '192.168.1.1'"
    * Modify connection "bridge-br0" changing options "ipv4.dns 8.8.8.8 ipv4.dns-search redhat.com"
    * Bring up connection "bridge-br0"
    * Add a new connection of type "bond" and options "ifname bond0 con-name bond-bond0 autoconnect no mode active-backup"
    * Modify connection "bond-bond0" changing options "ipv4.method disabled ipv6.method ignore connection.autoconnect yes"
    * Bring up connection "bond-bond0"
    * Add a new connection of type "bond-slave" and options "ifname eth1 con-name bond-slave-eth1 master bond0"
    * Add a new connection of type "bond-slave" and options "ifname eth2 con-name bond-slave-eth2 master bond0"
    * Add a new connection of type "vlan" and options "ifname vlan10 con-name vlan-vlan10 autoconnect no dev bond0 id 10"
    * Modify connection "vlan-vlan10" changing options "connection.master br0 connection.slave-type bridge connection.autoconnect yes"
    * Bring up connection "vlan-vlan10"
    # Check all is up
    * "connected:bond-slave-eth1" is visible with command "nmcli -t -f STATE,CONNECTION device" in "5" seconds
    * "connected:bond-slave-eth2" is visible with command "nmcli -t -f STATE,CONNECTION device" in "5" seconds
    # Delete bridge and bond outside NM, leaving the vlan device (with its mac set)
    * Finish "systemctl stop NetworkManager.service"
    * Finish "ip link del bond0"
    * Finish "ip link del br0"
    * Finish "systemctl start NetworkManager.service"
    # Check the configuration has been restored in full after by NM again
    Then "connected:bridge-br0" is visible with command "nmcli -t -f STATE,CONNECTION device" in "5" seconds
    Then "connected:vlan-vlan10" is visible with command "nmcli -t -f STATE,CONNECTION device"
    Then "connected:bond-bond0" is visible with command "nmcli -t -f STATE,CONNECTION device"
    Then "connected:bond-slave-eth1" is visible with command "nmcli -t -f STATE,CONNECTION device"
    Then "connected:bond-slave-eth2" is visible with command "nmcli -t -f STATE,CONNECTION device"
    * Note the output of "ip a s bond0 | grep link/ether | awk '{print $2}'" as value "bond_mac"
    * Note the output of "ip a s vlan10 | grep link/ether | awk '{print $2}'" as value "vlan_mac"
    # And that the VLAN mac has changed according to the recreated other devices
    Then Check noted values "bond_mac" and "vlan_mac" are the same


    @rhbz1300755
    @ver+=1.4.0
    @vlan @del_test1112_veths @ipv4
    @bring_up_very_long_device_name
    Scenario: nmcli - general - bring up very_long_device_name
    * Execute "ip link add very_long_name type veth peer name test11"
    * Add a new connection of type "ethernet" and options "ifname very_long_name con-name ethie -- ipv4.method manual ipv4.addresses 1.2.3.4/24"
    * Bring "up" connection "ethie"
    * Add a new connection of type "vlan" and options "dev very_long_name id 1024 con-name vlan -- ipv4.method manual ipv4.addresses 1.2.3.55/24"
    * Bring "up" connection "vlan"
    Then "very_long_name:connected:ethie" is visible with command "nmcli -t -f DEVICE,STATE,CONNECTION device" in "10" seconds
     And "very_long_.1024:connected:vlan" is visible with command "nmcli -t -f DEVICE,STATE,CONNECTION device" in "10" seconds
     And "inet 1.2.3.4\/24" is visible with command "ip a s very_long_name"
     And "inet 1.2.3.55\/24" is visible with command "ip a s very_long_.1024"
