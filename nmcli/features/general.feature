@testplan
Feature: nmcli - general

    @general
    @logging
    Scenario: NM - general - setting log level and autocompletion
    Then "DEBUG\s+ERR\s+INFO\s+TRACE\s+WARN" is visible with tab after "sudo nmcli general logging level "
    * Set logging for "all" to "INFO"
    Then "INFO\s+PLATFORM,RFKILL,ETHER,WIFI,BT,MB,DHCP4,DHCP6,PPP,WIFI_SCAN,IP4,IP6,AUTOIP4,DNS,VPN,SHARING,SUPPLICANT,AGENTS,SETTINGS,SUSPEND,CORE,DEVICE,OLPC,WIMAX,INFINIBAND,FIREWALL,ADSL,BOND,VLAN,BRIDGE,DBUS_PROPS,TEAM,CONCHECK,DCB,DISPATCH" is visible with command "nmcli general logging"
    * Set logging for "default,WIFI:ERR" to " "
    Then "INFO\s+PLATFORM,RFKILL,ETHER,WIFI:ERR,BT,MB,DHCP4,DHCP6,PPP,IP4,IP6,AUTOIP4,DNS,VPN,SHARING,SUPPLICANT,AGENTS,SETTINGS,SUSPEND,CORE,DEVICE,OLPC,WIMAX,INFINIBAND,FIREWALL,ADSL,BOND,VLAN,BRIDGE,TEAM,CONCHECK,DCB,DISPATCH" is visible with command "nmcli general logging"

    @general
    @testcase_290423
    Scenario: nmcli - general - check version
    * Note the output of "rpm -q --queryformat '%{VERSION}' NetworkManager" as value "1"
    * Note the output of "nmcli -t -f VERSION general" as value "2"
    Then Check noted values "1" and "2" are the same


    @general
    @testcase_290424
    Scenario: nmcli - general - state connected
    * Note the output of "nmcli -t -f STATE general" as value "1"
    * Note the output of "echo connected" as value "2"
    Then Check noted values "1" and "2" are the same


    @general
    @restore_hostname
    @hostname_change
    Scenario: nmcli - general - set hostname
    * Execute "sudo nmcli general hostname walderon"
    Then "walderon" is visible with command "cat /etc/hostname"


    @general
    @restart
    @veth
    @testcase_290425
    Scenario: nmcli - general - state disconnected
    * "disconnect" all " connected" devices
    * Note the output of "nmcli -t -f STATE general" as value "1"
    * Note the output of "echo disconnected" as value "2"
    Then Check noted values "1" and "2" are the same
    * Bring up connection "testeth0"


    @general
    @veth
    @testcase_290426
    Scenario: nmcli - general - state asleep
    * Execute "nmcli networking off"
    * Note the output of "nmcli -t -f STATE general" as value "1"
    * Note the output of "echo asleep" as value "2"
    Then Check noted values "1" and "2" are the same
    Then Execute "nmcli networking on"


    @general
    @testcase_290427
    Scenario: nmcli - general - running
    * Note the output of "nmcli -t -f RUNNING general" as value "1"
    * Note the output of "echo running" as value "2"
    Then Check noted values "1" and "2" are the same


    @general
    @veth
    @restart
    @testcase_290428
    Scenario: nmcli - general - not running
    * Execute "sudo service NetworkManager stop"
    * Wait for at least "2" seconds
    Then "NetworkManager is not running" is visible with command "nmcli general"


    @general
    @testcase_290429
    Scenario: nmcli - general - networking
    * Note the output of "nmcli -t -f NETWORKING general" as value "1"
    * Note the output of "echo enabled" as value "2"
    Then Check noted values "1" and "2" are the same
    * Execute "nmcli networking off"
    * Note the output of "nmcli -t -f NETWORKING general" as value "3"
    * Note the output of "echo disabled" as value "4"
    Then Check noted values "3" and "4" are the same
    Then Execute "nmcli networking on"


    @general
    @testcase_290430
    Scenario: nmcli - networking - status - enabled
    * Note the output of "nmcli networking" as value "1"
    * Note the output of "echo enabled" as value "2"
    Then Check noted values "1" and "2" are the same


    @general
    @testcase_290431
    Scenario: nmcli - networking - status - disabled
    * Note the output of "nmcli networking" as value "1"
    * Note the output of "echo enabled" as value "2"
    * Check noted values "1" and "2" are the same
    * Execute "nmcli networking off"
    * Note the output of "nmcli networking" as value "3"
    * Note the output of "echo disabled" as value "4"
    Then Check noted values "3" and "4" are the same
    Then Execute "nmcli networking on"


    @general
    @veth
    @testcase_290432
    Scenario: nmcli - networking - turn off
    * "eth0:" is visible with command "ifconfig"
    * Execute "nmcli networking off"
    Then "eth0:" is not visible with command "ifconfig"
    Then Execute "nmcli networking on"


    @general
    @veth
    @testcase_290433
    Scenario: nmcli - networking - turn on
    * Execute "nmcli networking off"
    * "eth0:" is not visible with command "ifconfig"
    * Execute "nmcli networking on"
    Then "eth0:" is visible with command "ifconfig"


    @general
    @testcase_294542
    Scenario: nmcli - radio - status
    Then "WIFI-HW\s+WIFI\s+WWAN-HW\s+WWAN\s+enabled|disabled\s+enabled|disabled\s+enabled|disabled\s+enabled|disabled" is visible with command "nmcli radio"


    @general
    @testcase_294543
    Scenario: nmcli - device - status
    Then "DEVICE\s+TYPE\s+STATE.+eth0\s+ethernet" is visible with command "nmcli device"


    @general
    @ethernet
    @testcase_2945544
    Scenario: nmcli - device - show - check ip
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.10/24" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "ip = 192.168.1.10/24" is visible with command "nmcli device show eth1"


    @general
    @testcase_294545
    Scenario: nmcli - device - show - check general params
    * Note the output of "nmcli device show eth0"
    Then Check noted output contains "GENERAL.DEVICE:\s+eth0"
    Then Check noted output contains "GENERAL.TYPE:\s+ethernet"
    Then Check noted output contains "GENERAL.MTU:\s+[0-9]+"
    Then Check noted output contains "GENERAL.HWADDR:\s+\S+:\S+:\S+:\S+:\S+:\S+"
    Then Check noted output contains "GENERAL.CON-PATH:\s+\S+\s"
    Then Check noted output contains "GENERAL.CONNECTION:\s+\S+\s"


    @general
    @testcase_294546
    Scenario: nmcli - device - disconnect
    * Bring "up" connection "testeth1"
    * "eth1\s+ethernet\s+connected" is visible with command "nmcli device"
    * Disconnect device "eth1"
    Then "eth1\s+ethernet\s+connected" is not visible with command "nmcli device"


## Basically various bug related reproducer tests follow here

    @general
    @ethernet
    @device_connect
    Scenario: nmcli - device - connect
    * Bring "up" connection "testeth2"
    * Disconnect device "eth2"
    When "eth2\s+ethernet\s+ connected\s+eth2" is not visible with command "nmcli device"
    * Connect device "eth2"
    Then "eth2\s+ethernet\s+connected" is visible with command "nmcli device"


    @rhbz1113941
    @veth
    @general
    @device_connect_no_profile
    Scenario: nmcli - device - connect - no profile
    * Finish "nmcli connection delete id testeth2"
    * Connect device "eth2"
    * Bring "down" connection "eth2"
    Then "eth2" is not visible with command "nmcli connection show -a"
    Then "connection.interface-name: \s+eth2" is visible with command "nmcli connection show eth2"


    @rhbz1034150
    @general
    @bridge
    @nmcli_device_delete
    Scenario: nmcli - device - delete
    * Add a new connection of type "bridge" and options "ifname bridge0 con-name bridge0"
    * "bridge0\s+bridge" is visible with command "nmcli device"
    * Execute "nmcli device delete bridge0"
    Then "bridge0\s+bridge" is not visible with command "nmcli device"
    Then "bridge0" is visible with command "nmcli connection"


    @rhbz1034150
    @general
    @veth
    @nmcli_device_attempt_hw_delete
    Scenario: nmcli - device - attempt to delete hw interface
    * "eth9\s+ethernet" is visible with command "nmcli device"
    Then "Error" is visible with command "nmcli device delete eth9"
    Then "eth9\s+ethernet" is visible with command "nmcli device"


    @rhbz1067712
    @veth
    @general
    @ethernet
    @nmcli_general_correct_profile_activated_after_restart
    Scenario: nmcli - general - correct profile activated after restart
    * Bring down connection "eth9" ignoring error
    * Add a new connection of type "ethernet" and options "ifname eth9 con-name aaa"
    * Add a new connection of type "ethernet" and options "ifname eth9 con-name bbb"
    * Bring up connection "aaa"
    * Restart NM
    Then "bbb" is not visible with command "nmcli device"
    Then "aaa" is visible with command "nmcli device"


    @rhbz1007365
    @general
    @bridge
    @nmcli_novice_mode_readline
    Scenario: nmcli - general - using readline library in novice mode
    * Open wizard for adding new connection
    * Expect "Connection type"
    * Send "bond" in editor
    * Clear the text typed in editor
    * Submit "bridge" in editor
    Then Expect "arguments for 'bridge' connection"
    * Submit "no" in editor
    * Submit "no" in editor
    Then "nm-bridge" is visible with command "nmcli connection show bridge"


    @general
    @dns_none
    Scenario: NM - dns none setting
    * Execute "sudo sed -i 's/plugins=ifcfg-rh/plugins=ifcfg-rh\ndns=none/' /etc/NetworkManager/NetworkManager.conf"
    * Execute "sudo echo 'nameserver 1.2.3.4' > /etc/resolv.conf"
    * Execute "cat /etc/resolv.conf"
    * Restart NM
    * Bring "up" connection "testeth0"
    Then "nameserver 1.2.3.4" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 10" is not visible with command "cat /etc/resolv.conf"


    @general
    @remove_dns_none
    Scenario: NM - dns  none removal
    When "nameserver 1.2.3.4" is visible with command "cat /etc/resolv.conf"
    * Execute "sudo sed -i 's/dns=none/\n/' /etc/NetworkManager/NetworkManager.conf"
    * Restart NM
    * Bring "up" connection "testeth0"
    Then "nameserver 1.2.3.4" is not visible with command "cat /etc/resolv.conf"
    Then "nameserver 10" is visible with command "cat /etc/resolv.conf"


    @rhbz1136836
    @rhbz1173632
    @general
    @restart
    @connection_up_after_journald_restart
    Scenario: NM - general - bring up connection after journald restart
    #* Add connection type "ethernet" named "ethie" for device "eth1"
    #* Bring "up" connection "testeth0"
    * Finish "sudo systemctl restart systemd-journald.service"
    Then Bring "up" connection "testeth0"


    @rhbz1110436
    @general
    @restore_hostname
    @nmcli_general_dhcp_hostname_over_localhost
    Scenario: NM - general - dont take localhost as configured hostname
    * Note the output of "cat /etc/hostname" as value "orig_file"
    * Note the output of "hostname" as value "orig_cmd"
    * Check noted values "orig_file" and "orig_cmd" are the same
    * Execute "echo localhost.localdomain > /etc/hostname"
    * Wait for at least "5" seconds
    * Note the output of "hostname" as value "localh_cmd"
    # Check that setting the hostname to localhost have been ignored
    * Check noted values "orig_cmd" and "localh_cmd" are the same
    # Now set it to custom non-localhost value
    * Execute "echo myown.hostname > /etc/hostname"
    * Note the output of "echo myown.hostname" as value "nonlocalh_file"
    * Wait for at least "5" seconds
    * Note the output of "hostname" as value "nonlocalh_cmd"
    # Now see that the non-locahost value has been set
    Then Check noted values "nonlocalh_file" and "nonlocalh_cmd" are the same
    # Restoring orig. hostname in after_scenario


    @rhbz1136843
    @general
    @nmcli_general_ignore_specified_unamanaged_devices
    Scenario: NM - general - ignore specified unmanaged devices
    * Execute "ip link add name dnt type bond"
    # Still unmanaged
    * "dnt\s+bond\s+unmanaged" is visible with command "nmcli device"
    * Execute "ip link set dev dnt up"
    * "dnt\s+bond\s+disconnected" is visible with command "nmcli device"
    # Add a config rule to unmanage the device
    * Execute "echo -e \\n[keyfile]\\nunmanaged-devices=interface-name:dnt > /etc/NetworkManager/NetworkManager.conf"
    * Wait for at least "5" seconds
    # Now the device should be listed as unmanaged
    Then "dnt\s+bond\s+unmanaged" is visible with command "nmcli device"


    @vlan
    @general
    @nmcli_general_ifcfg_tailing_whitespace
    Scenario: nmcli - general - ifcfg tailing whitespace ignored
    * Add a new connection of type "vlan" and options "con-name eth1.99 autoconnect no dev eth1 id 99"
    * Check ifcfg-name file created for connection "eth1.99"
    * Execute "sed -i 's/PHYSDEV=eth1/PHYSDEV=eth2    /' /etc/sysconfig/network-scripts/ifcfg-eth1.99"
    * Execute "nmcli connection reload"
    Then "eth2" is visible with command "nmcli con show eth1.99"


    @mock
    @nmcli_device_wifi_with_two_devices
    Scenario: nmcli - device - wifi show two devices
    Then "test_two_wifi_with_accesspoints \(__main__.TestNetworkManager\) ... ok" is visible with command "sudo -u test python /mnt/tests/NetworkManager/tmp/dbusmock-unittest.py TestNetworkManager.test_two_wifi_with_accesspoints"


    @rhbz1114681
    @general
    @nmcli_general_keep_slave_device_unmanaged
    Scenario: nmcli - general - keep slave device unmanaged
    Given Check ifcfg-name file created for connection "testeth1"
    * Execute "echo -e NM_CONTROLLED=no >> /etc/sysconfig/network-scripts/ifcfg-testeth1"
    * Execute "nmcli connection reload"
    * Execute "ip link add link eth1 name eth1.100 type vlan id 100"
    Then "eth1\s+ethernet\s+unmanaged" is visible with command "nmcli device" in "5" seconds
    Then "eth1.100\s+vlan\s+unmanaged" is visible with command "nmcli device"
    Then "testeth1" is not visible with command "nmcli device"


    @rhbz1103777
    @no_error_when_firewald_restarted
    @firewall
    Scenario: NM - general - no error when firewalld restarted
    * Execute "sudo service firewalld restart"
    Then "nm_connection_get_setting_connection: assertion `NM_IS_CONNECTION \(connection\)' failed" is not visible with command "sudo tail -n 30 /var/log/messages"

    @rhbz1041901
    @general
    @nmcli_general_multiword_autocompletion
    Scenario: nmcli - general - multiword autocompletion
    * Add a new connection of type "bond" and options "con-name 'Bondy connection 1'"
    * "Bondy connection 1" is visible with command "nmcli connection"
    * Autocomplete "nmcli connection delete Bondy" in bash and execute
    Then "Bondy connection 1" is not visible with command "nmcli connection" in "3" seconds


    @rhbz1170199
    @general
    @ethernet
    @IPy
    @nmcli_general_dbus_set_gateway
    Scenario: nmcli - general - dbus api gateway setting
    * Execute "python tmp/dbus-set-gw.py"
    Then "ipv4.gateway:\s+192.168.1.100" is visible with command "nmcli connection show ethos"


    @rhbz1141264
    @general
    @BBB
    @preserve_failed_assumed_connections
    Scenario: NM - general - presume failed assumed connections
    * Execute "ip tuntap add BBB mode tap"
    * Execute "ip addr add 10.2.5.6/24 valid_lft 1024 preferred_lft 1024 dev BBB"
    When "unmanaged" is visible with command "nmcli device show BBB"
    * Execute "ip link set dev BBB up"
    Then "connected" is visible with command "nmcli device show BBB" in "45" seconds


    @rhbz1066705
    @general
    @BBB
    @vxlan_interface_recognition
    Scenario: NM - general - vxlan interface support
    * Execute "/sbin/ip link add BBB type vxlan id 42 group 239.1.1.1 dev eth1"
    When "unmanaged" is visible with command "nmcli device show BBB"
    * Execute "ip link set dev BBB up"
    Then "connected" is visible with command "nmcli device show BBB" in "10" seconds
    Then vxlan device "BBB" check
