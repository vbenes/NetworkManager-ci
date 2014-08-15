Feature: Ethernet TUI tests

  Background:
  * Prepare virtual terminal environment

    @ethernet
    @nmtui_ethernet_create_default_connection
    Scenario: nmtui - ethernet - create default connection
    * Start nmtui
    * Choose to "Edit a connection" from main screen
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set current field to "ethernet"
    * Confirm the connection settings
    Then Check ifcfg-name file created for connection "ethernet"
    # any 192. IP after eth1 would be this one default connection IP
    Then "eth1.*inet 192." is visible with command "ip a" in "60" seconds
    Then "connected\s+ethernet" is visible with command "nmcli device"


    @ethernet
    @nmtui_ethernet_create_device_bound_connection
    Scenario: nmtui - ethernet - create device bound connection
    * Start nmtui
    * Choose to "Edit a connection" from main screen
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set current field to "ethernet"
    * Set "Device" field to "eth2"
    * Confirm the connection settings
    Then Check ifcfg-name file created for connection "ethernet"
    Then "eth2.*inet 192.*eth3" is visible with command "ip a" in "60" seconds
    Then "eth2\s+ethernet\s+connected\s+ethernet" is visible with command "nmcli device"


    @ethernet
    @nmtui_ethernet_create_connection_wo_autoconnect
    Scenario: nmtui - ethernet - create connection without autoconnect
    * Start nmtui
    * Choose to "Edit a connection" from main screen
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set current field to "ethernet"
    * Set "Device" field to "eth1"
    * Ensure "Automatically connect" is not checked
    * Confirm the connection settings
    Then Check ifcfg-name file created for connection "ethernet"
    Then "eth1\s+ethernet\s+disconnected" is visible with command "nmcli device"


    @ethernet
    @nmtui_ethernet_activate_connection
    Scenario: nmtui - ethernet - activate connection
    * Start nmtui
    * Choose to "Edit a connection" from main screen
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set current field to "ethernet"
    * Set "Device" field to "eth1"
    * Ensure "Automatically connect" is not checked
    * Confirm the connection settings
    * Check ifcfg-name file created for connection "ethernet"
    * "eth1\s+ethernet\s+disconnected" is visible with command "nmcli device"
    * Exit nmtui via "<Quit>" button
    * Start nmtui
    * Choose to "Activate a connection" from main screen
    * Select connection "ethernet" in the list
    * Choose to "<Activate>" a connection
    Then "eth1.*inet 192.*eth2" is visible with command "ip a" in "60" seconds
    Then "eth1\s+ethernet\s+connected\s+ethernet" is visible with command "nmcli device"


    @ethernet
    @nmtui_ethernet_activate_connection_specific_device
    Scenario: nmtui - ethernet - activate connection on specific device
    * Start nmtui
    * Choose to "Edit a connection" from main screen
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set current field to "ethernet"
    * Ensure "Automatically connect" is not checked
    * Confirm the connection settings
    * Check ifcfg-name file created for connection "ethernet"
    * "eth1\s+ethernet\s+disconnected" is visible with command "nmcli device"
    * Execute "nmcli connection up eth7"
    * Execute "nmcli connection down eth7"
    * Exit nmtui via "<Quit>" button
    * Start nmtui
    * Choose to "Activate a connection" from main screen
    * Select connection "eth7" in the list
    * Select connection "ethernet" in the list
    * Choose to "<Activate>" a connection
    Then "inet 192" is visible with command "ip a s eth7" in "60" seconds
    Then "eth7\s+ethernet\s+connected\s+ethernet" is visible with command "nmcli device"


    @ethernet
    @nmtui_ethernet_deactivate_connection
    Scenario: nmtui - ethernet - deactivate connection
    * Execute "nmcli con add type ethernet con-name ethernet ifname eth1 autoconnect no"
    * Execute "nmcli con up ethernet"
    * Start nmtui
    * Choose to "Activate a connection" from main screen
    * Select connection "ethernet" in the list
    * Choose to "<Deactivate>" a connection
    Then "eth1\s+ethernet\s+disconnected" is visible with command "nmcli device" in "10" seconds
    Then "eth1.*inet 192.*eth2" is not visible with command "ip a"


    @ethernet
    @nmtui_ethernet_delete_connection_down
    Scenario: nmtui - ethernet - delete nonactive connection
    * Start nmtui
    * Choose to "Edit a connection" from main screen
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set current field to "ethernet1"
    * Set "Device" field to "eth1"
    * Ensure "Automatically connect" is not checked
    * Confirm the connection settings
    * Check ifcfg-name file created for connection "ethernet1"
    * "eth1\s+ethernet\s+disconnected" is visible with command "nmcli device"
    * Select connection "ethernet1" in the list
    * Choose to "<Delete>" a connection
    * Press "Delete" button in the dialog
    Then ifcfg-"ethernet1" file does not exist
    Then "ethernet1" is not visible with command "nmcli con"


    @ethernet
    @nmtui_ethernet_delete_connection_up
    Scenario: nmtui - ethernet - delete active connection
    * Start nmtui
    * Choose to "Edit a connection" from main screen
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set current field to "ethernet1"
    * Set "Device" field to "eth1"
    * Ensure "Automatically connect" is checked
    * Confirm the connection settings
    * Check ifcfg-name file created for connection "ethernet1"
    * "eth1\s+ethernet\s+connected" is visible with command "nmcli device" in "60" seconds
    * Select connection "ethernet1" in the list
    * Choose to "<Delete>" a connection
    * Press "Delete" button in the dialog
    Then ifcfg-"ethernet1" file does not exist
    Then "ethernet1" is not visible with command "nmcli con"
    Then "eth1\s+ethernet\s+disconnected" is visible with command "nmcli device"


    @ethernet
    @nmtui_ethernet_set_mtu
    Scenario: nmtui - ethernet - set mtu
    * Start nmtui
    * Choose to "Edit a connection" from main screen
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Set "Device" field to "eth1"
    * Come in "ETHERNET" category
    * Set "MTU" field to "128"
    * Confirm the connection settings
    Then "MTU=128" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet"
    Then "eth1.*mtu 128.*eth2" is visible with command "ip a" in "60" seconds


    @ethernet
    @nmtui_ethernet_mac_spoofing
    Scenario: nmtui - ethernet - mac spoofing
    * Start nmtui
    * Choose to "Edit a connection" from main screen
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Set "Device" field to "eth1"
    * Come in "ETHERNET" category
    * Set "Cloned MAC address" field to "f0:de:aa:fb:bb:cc"
    * Confirm the connection settings
    Then "ether f0:de:aa:fb:bb:cc" is visible with command "ip a" in "60" seconds
    Then "MACADDR=F0:DE:AA:FB:BB:CC" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet"


    @ethernet
    @nmtui_ethernet_static_ipv4
    Scenario: nmtui - ethernet - static IPv4 configuration
    * Prepare new connection of type "Ethernet" named "ethernet"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.1.10/24"
    * Confirm the connection settings
    Then "eth1.*inet 192.168.1.10/24.*eth2" is visible with command "ip a" in "10" seconds
    Then "eth1\s+ethernet\s+connected\s+ethernet" is visible with command "nmcli device"


    @ethernet
    @nmtui_ethernet_static_ipv6
    Scenario: nmtui - ethernet - static IPv6 configuration
    * Prepare new connection of type "Ethernet" named "ethernet"
    * Set "Device" field to "eth1"
    * Set "IPv6 CONFIGURATION" category to "Manual"
    * Come in "IPv6 CONFIGURATION" category
    * In "Addresses" property add "2607:f0d0:1002:51::4/64"
    * Confirm the connection settings
    Then "eth1.*inet6 2607:f0d0:1002:51::4/64.*eth2" is visible with command "ip a" in "10" seconds
    Then "eth1\s+ethernet\s+connected\s+ethernet" is visible with command "nmcli device"


    @ethernet
    @nmtui_ethernet_static_combined
    Scenario: nmtui - ethernet - static IPv4 and IPv6 combined
    * Prepare new connection of type "Ethernet" named "ethernet"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.1.10/24"
    * Set "IPv6 CONFIGURATION" category to "Manual"
    * Come in "IPv6 CONFIGURATION" category
    * In "Addresses" property add "2607:f0d0:1002:51::4/64"
    * Confirm the connection settings
    Then "eth1.*inet 192.168.1.10/24.*eth2" is visible with command "ip a" in "10" seconds
    Then "eth1.*inet6 2607:f0d0:1002:51::4/64.*eth2" is visible with command "ip a" in "10" seconds
    Then "eth1\s+ethernet\s+connected\s+ethernet" is visible with command "nmcli device"
