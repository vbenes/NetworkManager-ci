Feature: IPv4 TUI tests

  Background:
  * Prepare virtual terminal environment

    @ipv4
    @nmtui_ipv4_addresses_static_no_address
    Scenario: nmtui - ipv4 - addresses - static IPv4 without address
    * Prepare new connection of type "Ethernet" named "ethernet"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Confirm the connection settings
    Then ".*Error saving connection: ipv4.addresses.*this property cannot be empty for.*method=manual.*" is visible on screen


    @ipv4
    @nmtui_ipv4_addresses_static_no_mask
    Scenario: nmtui - ipv4 - addresses - static IPv4 without netmask
    * Prepare new connection of type "Ethernet" named "ethernet"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.1.10"
    * Confirm the connection settings
    Then "eth1.*inet 192.168.1.10/32.*eth2" is visible with command "ip a" in "10" seconds
    Then "eth1\s+ethernet\s+connected\s+ethernet" is visible with command "nmcli device"


    @ipv4
    @nmtui_ipv4_addresses_auto_with_manual
    Scenario: nmcli - ipv4 - addresses - auto with manual address present
    * Prepare new connection of type "Ethernet" named "ethernet"
    * Set "Device" field to "eth1"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "1.2.2.1/24"
    * Confirm the connection settings
    Then "eth1.*inet 192.168.*eth2" is visible with command "ip a" in "10" seconds
    Then "eth1.*inet 1.2.2.1/24.*eth2" is visible with command "ip a"
    Then "eth1\s+ethernet\s+connected\s+ethernet" is visible with command "nmcli device"


    @ipv4
    @nmtui_ipv4_addresses_IP_slash_invalid_netmask
    Scenario: nmtui - ipv4 - addresses - IP slash invalid netmask
    * Prepare new connection of type "Ethernet" named "ethernet"
    * Set "Device" field to "eth1"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.1.18/33"
    * Cannot confirm the connection settings


    @ipv4
    @nmtui_ipv4_addresses_IP_slash_netmask_and_gateway_manual
    Scenario: nmtui - ipv4 - addresses - IP slash netmask and gateway
    * Prepare new connection of type "Ethernet" named "ethernet"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.125.253/24"
    * Set "Gateway" field to "192.168.125.96"
    * Confirm the connection settings
    Then "GATEWAY=192.168.125.96" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet"
    Then "192.168.125.253/24" is visible with command "ip a s eth1"
    Then "default via 192.168.125" is not visible with command "ip route"
    Then "192.168.125.0/24 dev eth1" is visible with command "ip route"


    @ipv4
    @nmtui_ipv4_addresses_several_IPs_slash_netmask_and_gateway_manual
    Scenario: nmtui - ipv4 - addresses - several IPs slash netmask and route - manual
    * Prepare new connection of type "Ethernet" named "ethernet"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.125.101/24"
    * In this property also add "192.168.125.102/24"
    * In this property also add "192.168.125.103/24"
    * Set "Gateway" field to "192.168.125.96"
    * Confirm the connection settings
    Then "GATEWAY=192.168.125.96" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet"
    Then "192.168.125.101/24" is visible with command "ip a s eth1"
    Then "192.168.125.102/24" is visible with command "ip a s eth1"
    Then "192.168.125.103/24" is visible with command "ip a s eth1"
    Then "default via 192.168.125" is not visible with command "ip route"
    Then "192.168.125.0/24 dev eth1" is visible with command "ip route"


    @ipv4
    @nmtui_ipv4_addresses_several_IPs_slash_netmask_and_gateway_auto
    Scenario: nmtui - ipv4 - addresses - several IPs slash netmask and route - auto
    * Prepare new connection of type "Ethernet" named "ethernet"
    * Set "Device" field to "eth1"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.253.101/24"
    * In this property also add "192.168.253.102/24"
    * In this property also add "192.168.253.103/24"
    * Set "Gateway" field to "192.168.253.96"
    * Confirm the connection settings
    Then "GATEWAY=192.168.253.96" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet"
    Then "192.168.*192.168.253.101" is visible with command "ip a s eth1" in "10" seconds
    Then "192.168.253.101/24" is visible with command "ip a s eth1"
    Then "192.168.253.102/24" is visible with command "ip a s eth1"
    Then "192.168.253.103/24" is visible with command "ip a s eth1"
    Then "default via 192.168.253" is not visible with command "ip route"
    Then "192.168.253.0/24 dev eth1" is visible with command "ip route"


    @ipv4
    @nmtui_ipv4_addresses_delete_ip_and_back_to_auto
    Scenario: nmtui - ipv4 - addresses - delete IP and set method back to auto
    * Prepare new connection of type "Ethernet" named "ethernet"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.253.101/24"
    * In this property also add "192.168.253.102/24"
    * In this property also add "192.168.253.103/24"
    * Set "Gateway" field to "192.168.253.96"
    * Confirm the connection settings
    * Select connection "ethernet" in the list
    * Choose to "<Edit...>" a connection
    * Set "IPv4 CONFIGURATION" category to "Automatic"
    * Come in "IPv4 CONFIGURATION" category
    * Remove all "Addresses" property items
    * Confirm the connection settings
    * Execute "nmcli con up ethernet"
    Then "192.168.253.101/24" is not visible with command "ip a s eth1"
    Then "192.168.253.102/24" is not visible with command "ip a s eth1"
    Then "192.168.253.103/24" is not visible with command "ip a s eth1"
    Then "192.168.253.96" is not visible with command "ip route"


    @ipv4
    @nmtui_ipv4_routes_set_basic_route
    Scenario: nmtui - ipv4 - routes - set basic route
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.3.10/24"
    * Set "Gateway" field to "192.168.4.1"
    * Add ip route "192.168.5.0/24 192.168.3.11 1"
    * Confirm the connection settings
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet2"
    * Set "Device" field to "eth2"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.1.10/24"
    * Set "Gateway" field to "192.168.4.1"
    * Add ip route "192.168.2.0/24 192.168.1.11 2"
    * Confirm the connection settings
    Then "192.168.1.0/24 dev eth2  proto kernel  scope link  src 192.168.1.10" is visible with command "ip route"
    Then "192.168.2.0/24 via 192.168.1.11 dev eth2  proto static  metric 2" is visible with command "ip route"
    Then "192.168.3.0/24 dev eth1  proto kernel  scope link  src 192.168.3.10" is visible with command "ip route"
    Then "192.168.5.0/24 via 192.168.3.11 dev eth1  proto static  metric 1" is visible with command "ip route"
    Then "default via [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ dev eth0" is visible with command "ip route"


    @ipv4
    @nmtui_ipv4_routes_remove_basic_route
    Scenario: nmtui - ipv4 - routes - remove basic route
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.3.10/24"
    * Set "Gateway" field to "192.168.4.1"
    * Add ip route "192.168.5.0/24 192.168.3.11 1"
    * Confirm the connection settings
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet2"
    * Set "Device" field to "eth2"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.1.10/24"
    * Set "Gateway" field to "192.168.4.1"
    * Add ip route "192.168.2.0/24 192.168.1.11 2"
    * Confirm the connection settings
    * Select connection "ethernet1" in the list
    * Choose to "<Edit...>" a connection
    * Come in "IPv4 CONFIGURATION" category
    * Remove all routes
    * Confirm the connection settings
    * Exit nmtui via "<Quit>" button
    * Start nmtui
    * Choose to "Edit a connection" from main screen
    * Select connection "ethernet2" in the list
    * Choose to "<Edit...>" a connection
    * Come in "IPv4 CONFIGURATION" category
    * Remove all routes
    * Confirm the connection settings
    * Execute "nmcli con up ethernet1"
    * Execute "nmcli con up ethernet2"
    Then "192.168.1.0/24 dev eth2  proto kernel  scope link  src 192.168.1.10" is visible with command "ip route"
    Then "192.168.2.0/24 via 192.168.1.11 dev eth2  proto static  metric 2" is not visible with command "ip route"
    Then "192.168.3.0/24 dev eth1  proto kernel  scope link  src 192.168.3.10" is visible with command "ip route"
    Then "192.168.5.0/24 via 192.168.3.11 dev eth1  proto static  metric 1" is not visible with command "ip route"
    Then "default via [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ dev eth0" is visible with command "ip route"

    @ipv4
    @nmtui_ipv4_routes_set_device_route
    Scenario: nmtui - ipv4 - routes - set device route
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.122.2/24"
    * Set "Gateway" field to "192.168.122.1"
    * Add ip route "192.168.1.0/24 0.0.0.0"
    * Add ip route "192.168.2.0/24 192.168.122.5"
    * Confirm the connection settings
    Then "192.168.1.0/24 dev eth1  proto static  scope link  metric" is visible with command "ip route"
    Then "192.168.2.0/24 via 192.168.122.5 dev eth1  proto static  metric" is visible with command "ip route"
    Then "192.168.122.0/24 dev eth1  proto kernel  scope link  src 192.168.122.2" is visible with command "ip route"


    @ipv4
    @nmtui_ipv4_routes_set_invalid_route_destination
    Scenario: nmtui - ipv4 - routes - set invalid route - destination
    * Start nmtui
    * Choose to "Edit a connection" from main screen
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Come in "IPv4 CONFIGURATION" category
    Then Cannot add ip route "192.168.1.256/24"
    * Press "ENTER" key
    Then Cannot add ip route "192.05.1.142"
    * Press "ENTER" key
    Then Cannot add ip route "192.256.1.142"
    * Press "ENTER" key
    Then Cannot add ip route "192.168.1.142/33"
    * Press "ENTER" key
    Then Cannot add ip route "000.000.000.000/32"
    * Press "ENTER" key
    Then Cannot add ip route ".../32"
    * Press "ENTER" key
    Then Cannot add ip route "..."
    * Press "ENTER" key
    Then Cannot add ip route "string"


    @ipv4
    @nmtui_ipv4_routes_set_invalid_route_hop
    Scenario: nmtui - ipv4 - routes - set invalid route - hop
    * Start nmtui
    * Choose to "Edit a connection" from main screen
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Come in "IPv4 CONFIGURATION" category
    Then Cannot add ip route "192.168.1.10/24 192.168.1.256"
    * Press "ENTER" key
    Then Cannot add ip route "192.168.1.10/24 192.05.1.142"
    * Press "ENTER" key
    Then Cannot add ip route "192.168.1.10/24 192.256.1.142"
    * Press "ENTER" key
    Then Cannot add ip route "192.168.1.10/24 192.168.1.142/33"
    * Press "ENTER" key
    Then Cannot add ip route "192.168.1.10/24 192.168.1.142/24"
    * Press "ENTER" key
    Then Cannot add ip route "192.168.1.10/24 000.000.000.000"
    * Press "ENTER" key
    Then Cannot add ip route "192.168.1.10/24 ..."
    * Press "ENTER" key
    Then Cannot add ip route "192.168.1.10/24 123456789"


    @ipv4
    @nmtui_ipv4_routes_set_unreachable_route
    Scenario: nmtui - ipv4 - routes - set unreachable route
    * Prepare new connection of type "Ethernet" named "ethernet"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.122.2/24"
    * Set "Gateway" field to "192.168.122.1"
    * Add ip route "192.168.1.0/24 192.168.3.11 1"
    * Confirm the connection settings
    * Exit nmtui via "<Quit>" button
    * Start nmtui
    * Choose to "Activate a connection" from main screen
    * Select connection "ethernet" in the list
    * Choose to "<Activate>" a connection
    Then ".*Could not activate connection.*" is visible on screen


    @ipv4
    @nmtui_ipv4_dns_method_static_+_IP_+_dns
    Scenario: nmtui - ipv4 - dns - method static + IP + dns
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.122.2/24"
    * Set "Gateway" field to "192.168.122.1"
    * In "DNS servers" property add "8.8.8.8"
    * In this property also add "8.8.4.4"
    * Confirm the connection settings
    Then "nameserver 8.8.8.8.*nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf" in "10" seconds


    @ipv4
    @nmtui_ipv4_dns_method_auto_+_dns
    Scenario: nmtui - ipv4 - dns - method auto + dns
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Set "Device" field to "eth1"
    * Come in "IPv4 CONFIGURATION" category
    * In "DNS servers" property add "8.8.8.8"
    * In this property also add "8.8.4.4"
    * Confirm the connection settings
    Then "nameserver 8.8.8.8.*nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf" in "10" seconds


    @ipv4
    @nmtui_ipv4_dns_add_dns_when_one_already_set
    Scenario: nmtui - ipv4 - dns - add dns when one already set
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Manual"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.122.2/24"
    * Set "Gateway" field to "192.168.122.1"
    * In "DNS servers" property add "8.8.8.8"
    * Confirm the connection settings
    * Select connection "ethernet1" in the list
    * Choose to "<Edit...>" a connection
    * Come in "IPv4 CONFIGURATION" category
    * Set "DNS servers" field to "8.8.8.8"
    * In this property also add "8.8.4.4"
    * Confirm the connection settings
    * Execute "nmcli connection up ethernet1"
    Then "nameserver 8.8.8.8.*nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf" in "10" seconds


    @ipv4
    @nmtui_ipv4_dns_method_auto_then_delete_all_dns
    Scenario: nmtui - ipv4 - dns - method auto then delete all dns
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Set "Device" field to "eth1"
    * Come in "IPv4 CONFIGURATION" category
    * In "DNS servers" property add "8.8.8.8"
    * In this property also add "8.8.4.4"
    * Confirm the connection settings
    * "nameserver 8.8.8.8.*nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf" in "10" seconds
    * Select connection "ethernet1" in the list
    * Choose to "<Edit...>" a connection
    * Come in "IPv4 CONFIGURATION" category
    * Remove all "DNS servers" property items
    * Confirm the connection settings
    * Execute "nmcli connection up ethernet1"
    Then "nameserver 8.8.8.8" is not visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is not visible with command "cat /etc/resolv.conf"


    @ipv4
    @nmtui_ipv4_dns_search_add_dns_search
    Scenario: nmtui - ipv4 - dns-search - add dns-search
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Set "Device" field to "eth1"
    * Come in "IPv4 CONFIGURATION" category
    * In "Search domains" property add "redhat.com"
    * Confirm the connection settings
    Then " redhat.com" is visible with command "cat /etc/resolv.conf" in "10" seconds


    @ipv4
    @nmtui_ipv4_dns_search_remove_dns_search
    Scenario: nmtui - ipv4 - dns-search - remove dns-search
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Set "Device" field to "eth1"
    * Come in "IPv4 CONFIGURATION" category
    * In "Search domains" property add "redhat.com"
    * Confirm the connection settings
    * " redhat.com" is visible with command "cat /etc/resolv.conf" in "10" seconds
    * Select connection "ethernet1" in the list
    * Choose to "<Edit...>" a connection
    * Come in "IPv4 CONFIGURATION" category
    * Remove all "Search domains" property items
    * Confirm the connection settings
    * Execute "nmcli connection up ethernet1"
    Then " redhat.com" is not visible with command "cat /etc/resolv.conf"


    @ipv4
    @nmtui_ipv4_method_link_local
    Scenario: nmtui - ipv4 - method - link-local
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Link-Local"
    * Confirm the connection settings
    Then "169.254" is visible with command "ip a s eth1" in "10" seconds


    @bz1108839
    @ipv4
    @nmtui_ipv4_may_connection_required
    Scenario: nmtui - ipv4 -  connection required
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Come in "IPv4 CONFIGURATION" category
    * Ensure "Require IPv4 addressing for this connection" is checked
    * Confirm the connection settings
    Then "IPV4_FAILURE_FATAL=yes" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet1"
    Then "ipv4.may-fail:\s+no" is visible with command "nmcli con show ethernet1"


    @bz1108839
    @ipv4
    @nmtui_ipv4_may_connection_not_required
    Scenario: nmtui - ipv4 -  connection not required
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Come in "IPv4 CONFIGURATION" category
    * Ensure "Require IPv4 addressing for this connection" is not checked
    * Confirm the connection settings
    Then "IPV4_FAILURE_FATAL=no" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet1"
    Then "ipv4.may-fail:\s+yes" is visible with command "nmcli con show ethernet1"


    @ipv4
    @nmtui_ipv4_method_disabled
    Scenario: nmtui - ipv4 - method - disabled
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Set "Device" field to "eth1"
    * Set "IPv4 CONFIGURATION" category to "Disabled"
    * Set "IPv6 CONFIGURATION" category to "Manual"
    * Come in "IPv6 CONFIGURATION" category
    * In "Addresses" property add "::1"
    * Confirm the connection settings
    Then "inet\s" is not visible with command "ip a s eth1"


    @ipv4
    @nmtui_ipv4_never_default_unset
    Scenario: nmtui - ipv4 - never-default - unset
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Come in "IPv4 CONFIGURATION" category
    * Ensure "Never use this network for default route" is not checked
    * Confirm the connection settings
    Then "DEFROUTE=yes" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet1"
    Then "ipv4.never-default:\s+no" is visible with command "nmcli con show ethernet1"


    @ipv4
    @nmtui_ipv4_never_default_set
    Scenario: nmtui - ipv4 - never-default - set
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Come in "IPv4 CONFIGURATION" category
    * Ensure "Never use this network for default route" is checked
    * Confirm the connection settings
    Then "DEFROUTE=no" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet1"
    Then "ipv4.never-default:\s+yes" is visible with command "nmcli con show ethernet1"


    @ipv4
    @nmtui_ipv4_invalid_address
    Scenario: nmtui - ipv4 - invalid address
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.1.256"
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.05.1.142"
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "192.168.1.142/33"
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "000.000.000.000"
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "..."
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * In "Addresses" property add "123456789"
    Then Cannot confirm the connection settings


    @ipv4
    @nmtui_ipv4_invalid_gateway
    Scenario: nmtui - ipv4 - invalid gateway
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Come in "IPv4 CONFIGURATION" category
    * Set "Gateway" field to "192.168.1.256"
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * Set "Gateway" field to "192.05.1.142"
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * Set "Gateway" field to "192.168.1.142/33"
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * Set "Gateway" field to "000.000.000.000"
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * Set "Gateway" field to "..."
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * Set "Gateway" field to "123456789"
    Then Cannot confirm the connection settings


    @ipv4
    @nmtui_ipv4_invalid_dns
    Scenario: nmtui - ipv4 - invalid dns
    * Prepare new connection of type "Ethernet" named "ethernet1"
    * Come in "IPv4 CONFIGURATION" category
    * In "DNS servers" property add "192.168.1.256"
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * In "DNS servers" property add "192.05.1.142"
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * In "DNS servers" property add "192.168.1.142/33"
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * In "DNS servers" property add "000.000.000.000"
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * In "DNS servers" property add "..."
    * Cannot confirm the connection settings
    * Press "ENTER" key
    * Choose to "<Add>" a connection
    * Choose the connection type "Ethernet"
    * Set "Profile name" field to "ethernet"
    * Come in "IPv4 CONFIGURATION" category
    * In "DNS servers" property add "123456789"
    Then Cannot confirm the connection settings