@testplan
Feature: nmcli - ethernet

 # Background:
 #   * Close Evolution and cleanup data

    @cleanethernet
    Scenario: Clean ethernet
    * "eth0" is visible with command "ifconfig"

    @ethernet
    @testcase_286577
    Scenario: nmcli - ethernet - create with editor
    * Open editor for a type "ethernet"
    * Set a property named "ipv4.method" to "auto" in editor
    * Set a property named "connection.interface-name" to "eth1" in editor
    * Set a property named "connection.autoconnect" to "no" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Note the "connection.id" property from editor print output
    * Quit editor
     Then Check ifcfg-name file created with noted connection name


    @ethernet
    @testcase_286578
    Scenario: nmcli - ethernet - create default connection
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet"
    Then Check ifcfg-name file created for connection "ethernet"


    @ethernet
    @testcase_286579
    Scenario: nmcli - ethernet - up
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Check ifcfg-name file created for connection "ethernet"
    * "inet 10." is not visible with command "ifconfig eth1"
    * Bring up connection "ethernet"
    Then "inet 10." is visible with command "ifconfig eth1"


    @ethernet
    @testcase_286580
    Scenario: nmcli - ethernet - disconnect device
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect yes"
    * Check ifcfg-name file created for connection "ethernet"
    * Bring up connection "ethernet"
    * "inet 10." is visible with command "ifconfig eth1"
    * Disconnect device "eth1"
    Then "inet 10." is not visible with command "ifconfig eth1"


    @ethernet
    @testcase_286581
    Scenario: nmcli - ethernet - describe all
    * Open editor for a type "ethernet"
    Then Check "port|speed|duplex|auto-negotiate|mac-address|cloned-mac-address|mac-address-blacklist|mtu|s390-subchannels|s390-nettype|s390-options" are present in describe output for object "802-3-ethernet"


    @ethernet
    @testcase_286582
    Scenario: nmcli - ethernet - describe separately
    * Open editor for a type "ethernet"
    Then Check "\[port\]" are present in describe output for object "802-3-ethernet.port"
    Then Check "\[speed\]" are present in describe output for object "802-3-ethernet.speed"
    Then Check "\[duplex\]" are present in describe output for object "802-3-ethernet.duplex"
    Then Check "\[auto-negotiate\]" are present in describe output for object "802-3-ethernet.auto-negotiate"
    Then Check "\[mac-address\]" are present in describe output for object "802-3-ethernet.mac-address"
    Then Check "\[cloned-mac-address\]" are present in describe output for object "802-3-ethernet.cloned-mac-address"
    Then Check "\[mac-address-blacklist\]" are present in describe output for object "802-3-ethernet.mac-address-blacklist"
    Then Check "\[mtu\]" are present in describe output for object "802-3-ethernet.mtu"
    Then Check "\[s390-subchannels\]" are present in describe output for object "802-3-ethernet.s390-subchannels"
    Then Check "\[s390-nettype\]" are present in describe output for object "802-3-ethernet.s390-nettype"
    Then Check "\[s390-options\]" are present in describe output for object "802-3-ethernet.s390-options"


    @ethernet
    @testcase_286583
    Scenario: nmcli - ethernet - set matching mac adress
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Note the "ether" property from ifconfig output for device "eth1"
    * Open editor for connection "ethernet"
    * Set a property named "802-3-ethernet.mac-address" to "noted-value" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "inet 10." is visible with command "ifconfig eth1"


    @ethernet
    @testcase_286584
    Scenario: nmcli - ethernet - set non-existent mac adress
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "802-3-ethernet.mac-address" to "00:11:22:33:44:55" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    Then "no device found" is visible with command "nmcli connection up ethernet"


    @ethernet
    @testcase_286585
    Scenario: nmcli - ethernet - set blacklisted mac adress
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Note the "ether" property from ifconfig output for device "eth1"
    * Open editor for connection "ethernet"
    * Set a property named "802-3-ethernet.mac-address-blacklist" to "noted-value" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    Then "Error" is visible with command "nmcli connection up ethernet"


    @ethernet
    @testcase_286586
    Scenario: nmcli - ethernet - mac spoofing
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "802-3-ethernet.cloned-mac-address" to "f0:de:aa:fb:bb:cc" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "ether f0:de:aa:fb:bb:cc" is visible with command "ifconfig eth1"


    @ethernet
    @testcase_286587
    Scenario: nmcli - ethernet - set mtu
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "802-3-ethernet.mtu" to "64" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "MTU=64" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet"
    Then "inet 10." is visible with command "ifconfig eth1"


    @ethernet
    @testcase_286588
    Scenario: nmcli - ethernet - static IPv4 configuration
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.10/24" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "inet 192.168.1.10\s+netmask 255.255.255.0" is visible with command "ifconfig eth1"


    @ethernet
    @testcase_286589
    Scenario: nmcli - ethernet - static IPv6 configuration
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "ipv6.method" to "manual" in editor
    * Set a property named "ipv6.addresses" to "2607:f0d0:1002:51::4/64" in editor
    * Set a property named "ipv4.method" to "disabled" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "inet6 2607:f0d0:1002:51::4\s+prefixlen 64" is visible with command "ifconfig eth1"


    @ethernet
    @testcase_286590
    Scenario: nmcli - ethernet - static IPv4 and IPv6 combined configuration
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "ipv6.method" to "manual" in editor
    * Set a property named "ipv6.addresses" to "2607:f0d0:1002:51::4/64" in editor
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.10/24" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "inet 192.168.1.10\s+netmask 255.255.255.0" is visible with command "ifconfig eth1"
    Then "inet6 2607:f0d0:1002:51::4\s+prefixlen 64" is visible with command "ifconfig eth1"
