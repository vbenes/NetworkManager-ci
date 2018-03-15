    Feature: nmcli: ipv6

    # Please do use tags as follows:
    # @bugzilla_link (rhbz123456)
    # @version_control (ver+/-=1.4.1)
    # @other_tags (see environment.py)
    # @test_name (compiled from scenario name)
    # Scenario:


    @ipv6
    @ipv6_method_static_without_IP
    Scenario: nmcli - ipv6 - method - static without IP
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
      * Open editor for connection "ethie"
      * Submit "set ipv6.method static" in editor
      * Save in editor
    Then Error type "ipv6.addresses: this property cannot be empty for" while saving in editor


    @ipv6
    @ipv6_method_manual_with_IP
    Scenario: nmcli - ipv6 - method - manual + IP
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method manual" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4/64, 1050:0:0:0:5:600:300c:326b" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "2607:f0d0:1002:51::4/64" is visible with command "ip a s eth1" in "5" seconds
    Then "1050::5:600:300c:326b/128" is visible with command "ip a s eth1"


    @ipv6
    @ipv6_method_static_with_IP
    Scenario: nmcli - ipv6 - method - static + IP
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4, 1050:0:0:0:5:600:300c:326b" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "2607:f0d0:1002:51::4/128" is visible with command "ip a s eth1" in "5" seconds
    Then "1050::5:600:300c:326b/128" is visible with command "ip a s eth1"


    @ipv6
    @ipv6_addresses_IP_with_netmask
    Scenario: nmcli - ipv6 - addresses - IP slash netmask
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method manual" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4/63, 1050:0:0:0:5:600:300c:326b/121" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "2607:f0d0:1002:51::4/63" is visible with command "ip a s eth1" in "5" seconds
    Then "1050::5:600:300c:326b/121" is visible with command "ip a s eth1"
    # reproducer for 997759
    Then "IPV6_DEFAULTGW" is not visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethie"


    @ipv6
    @ipv6_addresses_yes_when_static_switch_asked
    Scenario: nmcli - ipv6 - addresses - IP and yes to manual question
     * Add a new connection of type "ethernet" and options "ifname eth10 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.addresses dead:beaf::1" in editor
     * Submit "yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     Then "inet6 dead:beaf" is visible with command "ip a s eth10" in "5" seconds
     Then "inet6 2620" is not visible with command "ip a s eth10" in "5" seconds


    @ipv6
    @ipv6_addresses_no_when_static_switch_asked
    Scenario: nmcli - ipv6 - addresses - IP and no to manual question
     * Add a new connection of type "ethernet" and options "ifname eth10 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.addresses dead:beaf::1" in editor
     * Submit "no" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     Then "inet6 dead:beaf" is visible with command "ip a s eth10" in "5" seconds
     Then "inet6 2620" is visible with command "ip a s eth10" in "5" seconds


    @ipv6 @eth0
    @ipv6_addresses_invalid_netmask
    Scenario: nmcli - ipv6 - addresses - IP slash invalid netmask
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4/321" in editor
    Then Error type "failed to set 'addresses' property: invalid prefix '321'; <1-128> allowed" while saving in editor


    @ipv6 @eth0
    @ipv6_addresses_IP_with_mask_and_gw
    Scenario: nmcli - ipv6 - addresses - IP slash netmask and gw
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4/64" in editor
     * Submit "set ipv6.gateway 2607:f0d0:1002:51::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "2607:f0d0:1002:51::4/64" is visible with command "ip a s eth1" in "5" seconds
    Then "default via 2607:f0d0:1002:51::1 dev eth1\s+proto static\s+metric" is visible with command "ip -6 route"


    @ipv6 @eth0
    @ipv6_addresses_set_several_IPv6s_with_masks_and_gws
    Scenario: nmcli - ipv6 - addresses - several IPs slash netmask and gw
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses fc01::1:5/68, fb01::1:6/112" in editor
     * Submit "set ipv6.addresses fc02::1:21/96" in editor
     * Submit "set ipv6.gateway fc01::1:1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "fc02::1:21/96" is visible with command "ip a s eth1" in "5" seconds
    Then "fc01::1:5/68" is visible with command "ip a s eth1"
    Then "fb01::1:6/112" is visible with command "ip a s eth1"
    Then "default via fc01::1:1 dev eth1" is visible with command "ip -6 route"


    @ipv6
    @ipv6_addresses_delete_IP_moving_method_back_to_auto
    Scenario: nmcli - ipv6 - addresses - delete IP and set method back to auto
     * Add a new connection of type "ethernet" and options "ifname eth10 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses fc01::1:5/68" in editor
     * Submit "set ipv6.gateway fc01::1:1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Open editor for connection "ethie"
     * Submit "set ipv6.addresses" in editor
     * Enter in editor
     * Submit "set ipv6.gateway" in editor
     * Enter in editor
     * Submit "set ipv6.method auto" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "fc01::1:5/68" is not visible with command "ip a s eth10" in "5" seconds
    Then "default via fc01::1:1 dev eth1" is not visible with command "ip -6 route"
    Then "2620:52:0:" is visible with command "ip a s eth10"


    @ipv6_2 @eth0
    @ver-=1.9.1
    @ipv6_routes_set_basic_route
    Scenario: nmcli - ipv6 - routes - set basic route
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2000::2/126" in editor
     * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
     * Save in editor
     * Quit editor
     * Add a new connection of type "ethernet" and options "ifname eth2 con-name ethie2 autoconnect no"
     * Open editor for connection "ethie2"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.routes 3030::1/128 2001::2 1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Bring "up" connection "ethie2"
    Then "1010::1 via 2000::1 dev eth1\s+proto static\s+metric 1" is visible with command "ip -6 route" in "5" seconds
    Then "2000::/126 dev eth1\s+proto kernel\s+metric 256" is visible with command "ip -6 route"
    Then "2001::/126 dev eth2\s+proto kernel\s+metric 256" is visible with command "ip -6 route"
    Then "3030::1 via 2001::2 dev eth2\s+proto static\s+metric 1" is visible with command "ip -6 route"


    @rhbz1505893
    @ipv6_2 @eth0
    @ver+=1.9.2
    @ipv6_routes_set_basic_route
    Scenario: nmcli - ipv6 - routes - set basic route
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2000::2/126" in editor
     * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
     * Save in editor
     * Quit editor
     * Add a new connection of type "ethernet" and options "ifname eth2 con-name ethie2 autoconnect no"
     * Open editor for connection "ethie2"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.routes 3030::1/128 2001::2 1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Bring "up" connection "ethie2"
    Then "1010::1 via 2000::1 dev eth1\s+proto static\s+metric 1" is visible with command "ip -6 route" in "5" seconds
    Then "2000::/126 dev eth1\s+proto kernel\s+metric 100" is visible with command "ip -6 route"
    Then "2001::/126 dev eth2\s+proto kernel\s+metric 101" is visible with command "ip -6 route"
    Then "3030::1 via 2001::2 dev eth2\s+proto static\s+metric 1" is visible with command "ip -6 route"


    @rhbz1373698
    @ver+=1.8.0
    @ver-=1.9.1
    @ipv6
    @ipv6_route_set_route_with_options
    Scenario: nmcli - ipv6 - routes - set route with options
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no ipv6.method manual ipv6.addresses 2000::2/126 ipv6.route-metric 258"
    * Execute "nmcli con modify ethie ipv6.routes '1010::1/128 2000::1 1024 cwnd=15 lock-mtu=true mtu=1600'"
    * Bring "up" connection "ethie"
    Then "1010::1 via 2000::1 dev eth1\s+proto static\s+metric 1024\s+mtu lock 1600 cwnd 15" is visible with command "ip -6 route" in "5" seconds
    Then "2000::/126 dev eth1\s+proto kernel\s+metric 256" is visible with command "ip -6 route"
     And "default" is visible with command "ip r |grep eth0"

    @rhbz1373698
    @ver+=1.9.2
    @ipv6
    @ipv6_route_set_route_with_options
    Scenario: nmcli - ipv6 - routes - set route with options
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no ipv6.method manual ipv6.addresses 2000::2/126 ipv6.route-metric 258"
    * Execute "nmcli con modify ethie ipv6.routes '1010::1/128 2000::1 1024 cwnd=15 lock-mtu=true mtu=1600'"
    * Bring "up" connection "ethie"
    Then "1010::1 via 2000::1 dev eth1\s+proto static\s+metric 1024\s+mtu lock 1600 cwnd 15" is visible with command "ip -6 route" in "5" seconds
    Then "2000::/126 dev eth1\s+proto kernel\s+metric 258" is visible with command "ip -6 route"
     And "default" is visible with command "ip r |grep eth0"


    @ipv6_2 @eth0
    @ver-=1.9.1
    @ipv6_routes_remove_basic_route
    Scenario: nmcli - ipv6 - routes - remove basic route
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2000::2/126" in editor
     * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
     * Save in editor
     * Quit editor
     * Add a new connection of type "ethernet" and options "ifname eth2 con-name ethie2 autoconnect no"
     * Open editor for connection "ethie2"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.routes 3030::1/128 2001::2 1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Bring "up" connection "ethie2"
     * Open editor for connection "ethie"
     * Submit "set ipv6.routes" in editor
     * Enter in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "ethie2"
     * Submit "set ipv6.routes" in editor
     * Enter in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Bring "up" connection "ethie2"
    Then "2000::2/126" is visible with command "ip a s eth1"
    Then "2001::1/126" is visible with command "ip a s eth2"
    Then "1010::1 via 2000::1 dev eth1\s+proto static\s+metric 1" is not visible with command "ip -6 route"
    Then "2000::/126 dev eth1\s+proto kernel\s+metric 256" is visible with command "ip -6 route" in "5" seconds
    Then "2001::/126 dev eth2\s+proto kernel\s+metric 256" is visible with command "ip -6 route"
    Then "3030::1 via 2001::2 dev eth2\s+proto static\s+metric 1" is not visible with command "ip -6 route"


    @rhbz1505893
    @ipv6_2 @eth0
    @ver+=1.9.2
    @ipv6_routes_remove_basic_route
    Scenario: nmcli - ipv6 - routes - remove basic route
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2000::2/126" in editor
     * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
     * Save in editor
     * Quit editor
     * Add a new connection of type "ethernet" and options "ifname eth2 con-name ethie2 autoconnect no"
     * Open editor for connection "ethie2"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.routes 3030::1/128 2001::2 1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Bring "up" connection "ethie2"
     * Open editor for connection "ethie"
     * Submit "set ipv6.routes" in editor
     * Enter in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "ethie2"
     * Submit "set ipv6.routes" in editor
     * Enter in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Bring "up" connection "ethie2"
    Then "2000::2/126" is visible with command "ip a s eth1"
    Then "2001::1/126" is visible with command "ip a s eth2"
    Then "1010::1 via 2000::1 dev eth1\s+proto static\s+metric 1" is not visible with command "ip -6 route"
    Then "2000::/126 dev eth1\s+proto kernel\s+metric 102" is visible with command "ip -6 route" in "5" seconds
    Then "2001::/126 dev eth2\s+proto kernel\s+metric 103" is visible with command "ip -6 route"
    Then "3030::1 via 2001::2 dev eth2\s+proto static\s+metric 1" is not visible with command "ip -6 route"


    @ipv6 @eth0
    @ver-=1.9.1
    @ipv6_routes_device_route
    Scenario: nmcli - ipv6 - routes - set device route
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.gateway 4000::1" in editor
     * Submit "set ipv6.routes 1010::1/128 :: 3, 3030::1/128 2001::2 2 " in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "default via 4000::1 dev eth1\s+proto static\s+metric" is visible with command "ip -6 route" in "5" seconds
    Then "3030::1 via 2001::2 dev eth1\s+proto static\s+metric 2" is visible with command "ip -6 route"
    Then "2001::/126 dev eth1\s+proto kernel\s+metric 256" is visible with command "ip -6 route"
    Then "1010::1 dev eth1\s+proto static\s+metric 3" is visible with command "ip -6 route"


    @ipv6 @eth0
    @ver+=1.9.2
    @ipv6_routes_device_route
    Scenario: nmcli - ipv6 - routes - set device route
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.gateway 4000::1" in editor
     * Submit "set ipv6.routes 1010::1/128 :: 3, 3030::1/128 2001::2 2 " in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "default via 4000::1 dev eth1\s+proto static\s+metric" is visible with command "ip -6 route" in "5" seconds
    Then "3030::1 via 2001::2 dev eth1\s+proto static\s+metric 2" is visible with command "ip -6 route"
    Then "2001::/126 dev eth1\s+proto kernel\s+metric 100" is visible with command "ip -6 route"
    Then "1010::1 dev eth1\s+proto static\s+metric 3" is visible with command "ip -6 route"


    @rhbz1452684
    @ipv6
    @ver+=1.10
    @ipv6_routes_with_src
    Scenario: nmcli - ipv6 - routes - set route with src
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no ipv6.method manual ipv6.addresses 2000::2/126 ipv6.route-metric 256"
     * Execute "nmcli con modify ethie ipv6.routes '1010::1/128 src=2000::2'"
     * Bring "up" connection "ethie"
    Then "1010::1 dev eth1\s+proto static\s+metric 256" is visible with command "ip -6 route"
     And "2000::\/126 dev eth1\s+proto kernel\s+metric 256" is visible with command "ip -6 route"


    @rhbz1436531
    @ver+=1.10
    @eth @flush_300
    @ipv6_route_set_route_with_tables
    Scenario: nmcli - ipv6 - routes - set route with tables
    * Add a new connection of type "ethernet" and options "ifname eth10 con-name ethie ipv6.route-table 300 ipv6.may-fail no"
    When "connected" is visible with command "nmcli -g state,device device |grep eth10$" in "20" seconds
     And "2620.* dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show table 300"
     And "2620.*\/64 dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show table 300"
     And "fe80::\/64 dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show table 300"
     And "default via fe80.* dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show table 300"
     And "eth10" is not visible with command "ip -6 r |grep -v fe80"
    * Execute "ip -6 route add table 300 2004::3/128 dev eth10"
    When "2004::3 dev eth10 metric 1024" is visible with command "ip -6 r show table 300"
     And "2620.* dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show table 300"
     And "2620.*\/64 dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show table 300"
     And "fe80::\/64 dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show table 300"
     And "default via fe80.* dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show table 300"
    * Bring "up" connection "ethie"
    When "connected" is visible with command "nmcli -g state,device device |grep eth10$" in "20" seconds
    Then "2004::3 dev eth10 metric 1024" is not visible with command "ip -6 r show table 300"
     And "2620.* dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show table 300"
     And "2620.*\/64 dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show table 300"
     And "fe80::\/64 dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show table 300"
     And "default via fe80.* dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show table 300"
     And "eth10" is not visible with command "ip -6 r |grep -v fe80"


    @rhbz1436531
    @ver+=1.10
    @ver-=1.10.99
    @eth @flush_300
    @ipv6_route_set_route_with_tables_reapply
    Scenario: nmcli - ipv6 - routes - set route with tables reapply
    * Add a new connection of type "ethernet" and options "ifname eth10 con-name ethie ipv6.may-fail no"
    When "connected" is visible with command "nmcli -g state,device device |grep eth10$" in "20" seconds
     And "2620.* dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show"
     And "2620.*::\/64 dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show"
     And "fe80::\/64 dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show"
     And "default via fe80.* dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show"
    * Execute "ip -6 route add table 300 2004::3/128 dev eth10"
    When "2004::3 dev eth10 metric 1024" is visible with command "ip -6 r show table 300"
     And "2620.* dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show"
     And "2620.*\/64 dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show"
     And "fe80::\/64 dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show"
     And "default via fe80.* dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show"
    * Execute "nmcli device reapply eth10"
    When "connected" is visible with command "nmcli -g state,device device |grep eth10$" in "20" seconds
    Then "2620.* dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show" in "20" seconds
     And "2004::3 dev eth10 metric 1024" is not visible with command "ip -6 r show table 300"
     And "2620.*\/64 dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show"
     And "fe80::\/64 dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show"
     And "default via fe80.* dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show"


    @rhbz1436531
    @ver+=1.11
    @eth @flush_300
    @ipv6_route_set_route_with_tables_reapply
    Scenario: nmcli - ipv4 - routes - set route with tables reapply
    * Add a new connection of type "ethernet" and options "ifname eth10 con-name ethie ipv6.may-fail no"
    When "connected" is visible with command "nmcli -g state,device device |grep eth10$" in "20" seconds
     And "2620.* dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show"
     And "2620.*\/64 dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show"
     And "fe80::\/64 dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show"
     And "default via fe80.* dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show"
    * Execute "ip -6 route add table 300 2004::3/128 dev eth10"
    When "2004::3 dev eth10 metric 1024" is visible with command "ip -6 r show table 300"
     And "2620.* dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show"
     And "2620.*\/64 dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show"
     And "fe80::\/64 dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show"
     And "default via fe80.* dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show"
    * Execute "nmcli device reapply eth10"
    When "connected" is visible with command "nmcli -g state,device device |grep eth10$" in "20" seconds
    Then "2620.* dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show" in "20" seconds
     And "2004::3 dev eth10 metric 1024" is visible with command "ip -6 r show table 300"
     And "2620.*\/64 dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show"
     And "fe80::\/64 dev eth10 proto kernel metric 10[0-2]" is visible with command "ip -6 r show"
     And "default via fe80.* dev eth10 proto ra metric 10[0-2]" is visible with command "ip -6 r show"


    @ipv6
    @ipv6_correct_slaac_setting
    Scenario: NM - ipv6 - correct slaac setting
     * Add a new connection of type "ethernet" and options "ifname eth10 con-name ethie autoconnect no"
     * Execute "nmcli connection modify ethie ipv6.may-fail no"
     * Bring "up" connection "ethie"
    Then "2620:52:0:.*::/64 dev eth10\s+proto ra" is visible with command "ip -6 r" in "20" seconds
    Then "2620:52:0:" is visible with command "ip -6 a s eth10 |grep 'global noprefix'" in "20" seconds


    @ipv6 @eth0 @long
    @ipv6_limited_router_solicitation
    Scenario: NM - ipv6 - limited router solicitation
     * Add connection type "ethernet" named "ethie" for device "eth9"
     * Bring "up" connection "ethie"
     * Finish "sudo tshark -i eth9 -Y frame.len==62 -V -x -a duration:120 > /tmp/solicitation.txt"
    Then Check solicitation for "eth9" in "/tmp/solicitation.txt"


    @rhbz1068673
    @ipv6
    @ipv6_block_just_routing_RA
    Scenario: NM - ipv6 - block just routing RA
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Bring "up" connection "ethie"
    Then "1" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/accept_ra" in "5" seconds
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/accept_ra_defrtr"
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/accept_ra_rtr_pref"
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/accept_ra_pinfo"


    @ipv6
    @ipv6_routes_invalid_IP
    Scenario: nmcli - ipv6 - routes - set invalid route - non IP
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.gateway 4000::1" in editor
     * Submit "set ipv6.routes non:rout:set:up" in editor
    Then Error type "failed to set 'routes' property:" while saving in editor


    @ipv6 @eth0
    @ver-=1.9.1
    @ipv6_routes_without_gw
    Scenario: nmcli - ipv6 - routes - set invalid route - missing gw
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.gateway 4000::1" in editor
     * Submit "set ipv6.routes 1010::1/128" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "default via 4000::1 dev eth1\s+proto static\s+metric" is visible with command "ip -6 route" in "5" seconds
    Then "2001::/126 dev eth1\s+proto kernel\s+metric 256" is visible with command "ip -6 route"
    Then "1010::1 dev eth1\s+proto static\s+metric" is visible with command "ip -6 route"

    @ipv6 @eth0
    @ver+=1.9.2
    @ipv6_routes_without_gw
    Scenario: nmcli - ipv6 - routes - set invalid route - missing gw
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.gateway 4000::1" in editor
     * Submit "set ipv6.routes 1010::1/128" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "default via 4000::1 dev eth1\s+proto static\s+metric" is visible with command "ip -6 route" in "5" seconds
    Then "2001::/126 dev eth1\s+proto kernel\s+metric 100" is visible with command "ip -6 route"
    Then "1010::1 dev eth1\s+proto static\s+metric" is visible with command "ip -6 route"


    @ipv6 @eth0
    @ipv6_dns_manual_IP_with_manual_dns
    Scenario: nmcli - ipv6 - dns - method static + IP + dns
     * Add a new connection of type "ethernet" and options "ifname eth10 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv4.may-fail no" in editor
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.gateway 4000::1" in editor
     * Submit "set ipv6.dns 4000::1, 5000::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "nameserver 4000::1" is visible with command "cat /etc/resolv.conf" in "5" seconds
    Then "nameserver 5000::1" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 10." is visible with command "cat /etc/resolv.conf"


    @ipv6 @eth0
    @ipv6_dns_auto_with_more_manually_set
    Scenario: nmcli - ipv6 - dns - method auto + dns
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv4.may-fail no" in editor
     * Submit "set ipv6.dns 4000::1, 5000::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "nameserver 4000::1" is visible with command "cat /etc/resolv.conf" in "5" seconds
    Then "nameserver 5000::1" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 192.168.100.1" is visible with command "cat /etc/resolv.conf"


    @ipv6
    @ipv6_dns_ignore-auto-dns_with_manually_set_dns
    Scenario: nmcli - ipv6 - dns - method auto + dns + ignore automaticaly obtained
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.ignore-auto-dns yes" in editor
     * Submit "set ipv6.dns 4000::1, 5000::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "nameserver 4000::1" is visible with command "cat /etc/resolv.conf" in "5" seconds
    Then "nameserver 5000::1" is visible with command "cat /etc/resolv.conf"


    @ipv6 @eth0
    @ipv6_dns_add_more_when_already_have_some
    Scenario: nmcli - ipv6 - dns - add dns when one already set
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.gateway 4000::1" in editor
     * Submit "set ipv6.dns 4000::1, 5000::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Open editor for connection "ethie"
     * Submit "set ipv6.dns 2000::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "nameserver 4000::1" is visible with command "cat /etc/resolv.conf" in "5" seconds
    Then "nameserver 5000::1" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 2000::1" is visible with command "cat /etc/resolv.conf"


    @ipv6 @eth0
    @ipv6_dns_remove_manually_set
    Scenario: nmcli - ipv6 - dns - method auto then delete all dns
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.dns 4000::1, 5000::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Open editor for connection "ethie"
     * Submit "set ipv6.dns" in editor
     * Enter in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "nameserver 4000::1" is not visible with command "cat /etc/resolv.conf"
    Then "nameserver 5000::1" is not visible with command "cat /etc/resolv.conf"


    @ipv6 @eth0
    @ipv6_dns-search_set
    Scenario: nmcli - ipv6 - dns-search - add dns-search
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv4.ignore-auto-dns yes" in editor
     * Submit "set ipv6.dns-search google.com" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "google.com" is visible with command "cat /etc/resolv.conf" in "5" seconds


    @ipv6 @eth0
    @ipv6_dns-search_remove
    Scenario: nmcli - ipv6 - dns-search - remove dns-search
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv4.ignore-auto-dns yes" in editor
     * Submit "set ipv6.dns-search google.com" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Open editor for connection "ethie"
     * Submit "set ipv6.dns-search" in editor
     * Enter in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then " google.com" is not visible with command "cat /etc/resolv.conf"


    @NM @ipv6 @eth0
    @ipv6_ignore-auto-dns_set
    Scenario: nmcli - ipv6 - ignore auto obtained dns
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv4.ignore-auto-dns yes" in editor
     * Submit "set ipv6.ignore-auto-dns yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then " google.com" is not visible with command "cat /etc/resolv.conf"
    Then "virtual" is not visible with command "cat /etc/resolv.conf"
    Then "nameserver " is not visible with command "cat /etc/resolv.conf" in "5" seconds


    @NM @ipv6 @eth0
    @ipv6_ignore-auto-dns_set-generic
    Scenario: nmcli - ipv6 - ignore auto obtained dns - generic
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv4.ignore-auto-dns yes" in editor
     * Submit "set ipv6.ignore-auto-dns yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then " google.com" is not visible with command "cat /etc/resolv.conf"
    Then "virtual" is not visible with command "cat /etc/resolv.conf"
    Then "nameserver " is not visible with command "cat /etc/resolv.conf" in "5" seconds


    @ipv6
    @ipv6_method_link-local
    Scenario: nmcli - ipv6 - method - link-local
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method link-local" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "inet6 fe80::" is visible with command "ip -6 a s eth1"
    Then "scope global" is not visible with command "ip -6 a s eth1"


    @ipv6
    @ipv6_may_fail_set_true
    Scenario: nmcli - ipv6 - may-fail - set true
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method dhcp" in editor
     * Submit "set ipv6.may-fail yes" in editor
     * Save in editor
     * Quit editor
    Then Bring "up" connection "ethie"


    @ipv6
    @ipv6_method_ignored
    Scenario: nmcli - ipv6 - method - ignored
     * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethie autoconnect no"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method static" in editor
     * Submit "set ipv4.addresses 192.168.122.253/24" in editor
     * Submit "set ipv6.method ignore" in editor
     * Save in editor
     * Quit editor
    Then Bring "up" connection "ethie"
    # VVV commented out because of fe80 is still on by kernel very likely
    # Then "scope link" is not visible with command "ip -6 a s eth10"
    Then "scope global" is not visible with command "ip a -6 s eth10" in "5" seconds
    # reproducer for 1004255
    Then Bring "down" connection "ethie"
    Then "eth10 " is not visible with command "ip -6 route |grep -v fe80"


    @ipv6
    @ipv6_never-default_set_true
    Scenario: nmcli - ipv6 - never-default - set
     * Add connection type "ethernet" named "ethie" for device "eth2"
     * Open editor for connection "ethie"
     * Submit "set ipv6.never-default yes " in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "testeth10"
     * Bring "up" connection "ethie"
    Then "default via " is not visible with command "ip -6 route |grep eth2" in "5" seconds


    @ipv6
    @ipv6_never-default_remove
    Scenario: nmcli - ipv6 - never-default - remove
     * Add connection type "ethernet" named "ethie" for device "eth2"
     * Open editor for connection "ethie"
     * Submit "set ipv6.never-default yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Open editor for connection "ethie"
     * Submit "set ipv6.never-default" in editor
     * Enter in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "testeth10"
     * Bring "up" connection "ethie"
    Then "default via " is not visible with command "ip -6 route |grep eth2" in "5" seconds


    @not_under_internal_DHCP @profie
    @ipv6_dhcp-hostname_set
    Scenario: nmcli - ipv6 - dhcp-hostname - set dhcp-hostname
    * Add a new connection of type "ethernet" and options "ifname eth9 con-name profie autoconnect no"
    * Run child "sudo tshark -i eth9 -f 'port 546' -V -x > /tmp/ipv6-hostname.log"
    * Finish "sleep 5"
    * Open editor for connection "profie"
    * Submit "set ipv6.may-fail true" in editor
    * Submit "set ipv6.method dhcp" in editor
    * Submit "set ipv6.dhcp-hostname r.cx" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "profie"
    * Finish "sleep 5"
    * Execute "sudo pkill tshark"
    Then "r.cx" is visible with command "grep r.cx /tmp/ipv6-hostname.log" in "5" seconds


    @not_under_internal_DHCP @ipv4
    @ipv6_dhcp-hostname_remove
    Scenario: nmcli - ipv6 - dhcp-hostname - remove dhcp-hostname
    * Add connection type "ethernet" named "ethie" for device "eth9"
    * Open editor for connection "ethie"
    * Submit "set ipv6.may-fail true" in editor
    * Submit "set ipv6.method dhcp" in editor
    * Submit "set ipv6.dhcp-hostname r.cx" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Bring "down" connection "ethie"
    * Finish "sleep 2"
    * Run child "sudo tshark -i eth9 -f 'port 546' -V -x > /tmp/tshark.log"
    * Wait for at least "10" seconds
    * Open editor for connection "ethie"
    * Submit "set ipv6.dhcp-hostname" in editor
    * Enter in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Finish "sleep 5"
    * Execute "sudo pkill tshark"
    Then "r.cx" is not visible with command "cat /tmp/tshark.log" in "5" seconds


    @restore_hostname @profie
    @ipv6_send_fqdn.fqdn_to_dhcpv6
    Scenario: NM - ipv6 - - send fqdn.fqdn to dhcpv6
    * Add a new connection of type "ethernet" and options "ifname eth9 con-name profie autoconnect no"
    * Execute "hostnamectl set-hostname dacan.local"
    * Run child "sudo tshark -i eth9 -f 'port 546' -V -x > /tmp/ipv6-hostname.log"
    * Finish "sleep 5"
    * Open editor for connection "profie"
    * Submit "set ipv6.method dhcp" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "profie"
    * Finish "sleep 5"
    * Execute "sudo pkill tshark"
    Then "dacan.local" is visible with command "cat /tmp/ipv6-hostname.log" in "5" seconds
    Then "0. = O bit" is visible with command "cat /tmp/ipv6-hostname.log" in "5" seconds


    @ipv6 @teardown_testveth
    @ipv6_secondary_address
    Scenario: nmcli - ipv6 - secondary
    * Prepare simulated test "testX" device
    * Add a new connection of type "ethernet" and options "ifname testX con-name ethie"
    * Bring "up" connection "ethie"
    Then "2" is visible with command "ip a s testX |grep 'inet6 .* global' |wc -l" in "10" seconds


    @ipv6
    @ipv6_ip6-privacy_0
    Scenario: nmcli - ipv6 - ip6_privacy - 0
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.ip6-privacy 2" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Finish "sleep 2"
    * Open editor for connection "ethie"
    * Submit "set ipv6.ip6-privacy 0" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    When "2620" is visible with command "ip a s eth10" in "10" seconds
     And "tentative dynamic" is not visible with command "ip a s eth10" in "10" seconds
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/use_tempaddr"
    Then "global temporary dynamic" is not visible with command "ip a s eth10" in "5" seconds


    @ipv6
    @ipv6_ip6-privacy_1
    Scenario: nmcli - ipv6 - ip6_privacy - 1
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.ip6-privacy 1" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    When "2620" is visible with command "ip a s eth10" in "10" seconds
     And "tentative dynamic" is not visible with command "ip a s eth10" in "10" seconds
    Then "1" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/use_tempaddr"
    Then Global temporary ip is not based on mac of device "eth10"


    @ipv6
    @ipv6_ip6-privacy_2
    Scenario: nmcli - ipv6 - ip6_privacy - 2
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.ip6-privacy 2" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    When "2620" is visible with command "ip a s eth10" in "10" seconds
     And "tentative dynamic" is not visible with command "ip a s eth10" in "10" seconds
    Then "2" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/use_tempaddr" in "5" seconds
    Then Global temporary ip is not based on mac of device "eth10"


    @rhbz1187525
    @ipv6 @privacy
    @ipv6_ip6-default_privacy
    Scenario: nmcli - ipv6 - ip6_privacy - default value
    * Execute "echo 1 > /proc/sys/net/ipv6/conf/default/use_tempaddr"
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Bring "up" connection "ethie"
    When "1" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/use_tempaddr"
    * Execute "echo '[connection.ip6-privacy]' > /etc/NetworkManager/conf.d/01-default-ip6-privacy.conf"
    * Execute "echo 'ipv6.ip6-privacy=2' >> /etc/NetworkManager/conf.d/01-default-ip6-privacy.conf"
    * Restart NM
    * Bring "down" connection "ethie"
    * Bring "up" connection "ethie"
    When "2" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/use_tempaddr"


    @ipv6
    @ipv6_ip6-privacy_incorrect_value
    Scenario: nmcli - ipv6 - ip6_privacy - incorrect value
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.ip6-privacy 3" in editor
    Then Error type "failed to set 'ip6-privacy' property: '3' is not valid\; use 0, 1, or 2" while saving in editor
    * Submit "set ipv6.ip6-privacy RHX" in editor
    Then Error type "failed to set 'ip6-privacy' property: 'RHX' is not a number" while saving in editor


    @rhbz1073824
    @veth @ipv6
    @ipv6_take_manually_created_ifcfg
    Scenario: ifcfg - ipv6 - use manually created link-local profile
    * Append "DEVICE='eth10'" to ifcfg file "ethie"
    * Append "ONBOOT=yes" to ifcfg file "ethie"
    * Append "NETBOOT=yes" to ifcfg file "ethie"
    * Append "UUID='aa17d688-a38d-481d-888d-6d69cca781b8'" to ifcfg file "ethie"
    * Append "BOOTPROTO=dhcp" to ifcfg file "ethie"
    * Append "TYPE=Ethernet" to ifcfg file "ethie"
    * Append "NAME='ethie'" to ifcfg file "ethie"
    * Restart NM
    Then "aa17d688-a38d-481d-888d-6d69cca781b8" is visible with command "nmcli -f UUID connection show -a"


    @rhbz1083283
    @scapy
    @ipv6_lifetime_set_from_network
    Scenario: NM - ipv6 - set lifetime from network
    * Finish "ip link add test10 type veth peer name test11"
    * Finish "nmcli c add type ethernet ifname test10"
    * Finish "nmcli c add type ethernet ifname test11"
    * Execute "nmcli con modify ethernet-test10 ipv4.method disabled ipv6.method auto"
    * Execute "nmcli con modify ethernet-test11 ipv4.method disabled ipv6.method auto ipv6.address dead::dead/128 ipv6.gateway dead::beaf/128"
    * Finish "ip link set dev test10 up"
    * Finish "ip link set dev test11 up"
    * Execute "nmcli --wait 0 c up ethernet-test10"
    * Execute "nmcli --wait 0 c up ethernet-test11"
    When "ethernet-test10" is visible with command "nmcli con sh -a"
    When "ethernet-test11" is visible with command "nmcli con sh -a"
    * Execute "sleep 15"
    * Send lifetime scapy packet
    Then "IPv6" lifetimes are slightly smaller than "3605" and "1805" for device "test11"


    @rhbz1318945
    @ver+=1.4.0
    @scapy
    @ipv6_lifetime_no_padding
    Scenario: NM - ipv6 - RA lifetime with no padding
    * Finish "ip link add test10 type veth peer name test11"
    * Finish "nmcli c add type ethernet ifname test10"
    * Finish "nmcli c add type ethernet ifname test11"
    * Execute "nmcli con modify ethernet-test10 ipv4.method disabled ipv6.method auto"
    * Execute "nmcli con modify ethernet-test11 ipv4.method disabled ipv6.method auto ipv6.address dead::dead/128 ipv6.gateway dead::beaf/128"
    * Finish "ip link set dev test10 up"
    * Finish "ip link set dev test11 up"
    * Execute "nmcli --wait 0 c up ethernet-test10"
    * Execute "nmcli --wait 0 c up ethernet-test11"
    When "ethernet-test10" is visible with command "nmcli con sh -a"
    When "ethernet-test11" is visible with command "nmcli con sh -a"
    * Execute "sleep 2"
    * Send lifetime scapy packet
    Then "IPv6" lifetimes are slightly smaller than "3600" and "1800" for device "test11"


    @rhbz1329366
    @ver+=1.4.0
    @scapy
    @ipv6_drop_ra_with_low_hlimit
    Scenario: NM - ipv6 - drop scapy packet with lower hop limit
    * Finish "ip link add test10 type veth peer name test11"
    * Finish "nmcli c add type ethernet ifname test10"
    * Finish "nmcli c add type ethernet ifname test11"
    * Execute "nmcli con modify ethernet-test10 ipv4.method disabled ipv6.method auto"
    * Execute "nmcli con modify ethernet-test11 ipv4.method disabled ipv6.method auto ipv6.address dead::dead/128 ipv6.gateway dead::beaf/128"
    * Finish "ip link set dev test10 up"
    * Finish "ip link set dev test11 up"
    * Execute "nmcli --wait 0 c up ethernet-test10"
    * Execute "nmcli --wait 0 c up ethernet-test11"
    When "ethernet-test10" is visible with command "nmcli con sh -a"
    When "ethernet-test11" is visible with command "nmcli con sh -a"
    * Execute "sleep 2"
    * Send lifetime scapy packet with "250"
    Then "valid_lft forever preferred_lft forever" is visible with command "ip a s test11"


    @rhbz1329366
    @ver+=1.4.0
    @scapy
    @ipv6_drop_ra_with_255_hlimit
    Scenario: NM - ipv6 - scapy packet with 255 hop limit
    * Finish "ip link add test10 type veth peer name test11"
    * Finish "nmcli c add type ethernet ifname test10"
    * Finish "nmcli c add type ethernet ifname test11"
    * Execute "nmcli con modify ethernet-test10 ipv4.method disabled ipv6.method auto"
    * Execute "nmcli con modify ethernet-test11 ipv4.method disabled ipv6.method auto ipv6.address dead::dead/128 ipv6.gateway dead::beaf/128"
    * Finish "ip link set dev test10 up"
    * Finish "ip link set dev test11 up"
    * Execute "nmcli --wait 0 c up ethernet-test10"
    * Execute "nmcli --wait 0 c up ethernet-test11"
    When "ethernet-test10" is visible with command "nmcli con sh -a"
    When "ethernet-test11" is visible with command "nmcli con sh -a"
    * Execute "sleep 2"
    * Send lifetime scapy packet with "255"
    Then "IPv6" lifetimes are slightly smaller than "3605" and "1805" for device "test11"


    @rhbz1329366
    @ver+=1.4.0
    @scapy
    @ipv6_drop_ra_from_non_ll_address
    Scenario: NM - ipv6 - drop scapy packet from non LL address
    * Finish "ip link add test10 type veth peer name test11"
    * Finish "nmcli c add type ethernet ifname test10"
    * Finish "nmcli c add type ethernet ifname test11"
    * Execute "nmcli con modify ethernet-test10 ipv4.method disabled ipv6.method auto"
    * Execute "nmcli con modify ethernet-test11 ipv4.method disabled ipv6.method auto ipv6.address dead::dead/128 ipv6.gateway dead::beaf/128"
    * Finish "ip link set dev test10 up"
    * Finish "ip link set dev test11 up"
    * Execute "nmcli --wait 0 c up ethernet-test10"
    * Execute "nmcli --wait 0 c up ethernet-test11"
    When "ethernet-test10" is visible with command "nmcli con sh -a"
    When "ethernet-test11" is visible with command "nmcli con sh -a"
    * Execute "sleep 2"
    * Send lifetime scapy packet from "ff02::1"
    Then "valid_lft forever preferred_lft forever" is visible with command "ip a s test11"


    @rhbz1170530
    @add_testeth10 @ipv6
    @ipv6_keep_connectivity_on_assuming_connection_profile
    Scenario: NM - ipv6 - keep connectivity on assuming connection profile
    * Add a new connection of type "ethernet" and options "con-name ethie ifname eth10 autoconnect no"
    * Bring up connection "ethie"
    * Wait for at least "20" seconds
    Then Check ipv6 connectivity is stable on assuming connection profile "ethie" for device "eth10"


    @rhbz1083133 @rhbz1098319 @rhbz1127718
    @veth @eth1_disconnect
    @ver-=1.11.1
    @ipv6_add_static_address_manually_not_active
    Scenario: NM - ipv6 - add a static address manually to non-active interface (legacy 1.10 behavior and older)
    Given "testeth1" is visible with command "nmcli connection"
    Given "eth1\s+ethernet\s+connected" is not visible with command "nmcli device"
    Given "state UP" is visible with command "ip a s eth1"
    * "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth1/disable_ipv6"
    * Execute "ip -6 addr add 2001::dead:beef:01/64 dev eth1"
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth1/disable_ipv6"
    Then "inet6 2001::dead:beef:1/64 scope global" is visible with command "ip a s eth1"
    # Newer versions of NM no longer create IPv6 LL addresses for externally assumed devices.
    # This test is obsoleted by @ipv6_add_static_address_manually_not_active_2, but this
    # behavior won't be backported to older versions.
    Then "addrgenmode none " is visible with command "ip -d l show eth1"
    Then "inet6 fe80" is visible with command "ip a s eth1" in "5" seconds
    # the assumed connection is created, give just some time for DAD to complete
    Then "eth1\s+ethernet\s+connected\s+eth1" is visible with command "nmcli device" in "5" seconds


    @rhbz1083133 @rhbz1098319 @rhbz1127718
    @veth @eth1_disconnect
    @ver+=1.11.2
    @ipv6_add_static_address_manually_not_active
    Scenario: NM - ipv6 - add a static address manually to non-active interface
    Given "testeth1" is visible with command "nmcli connection"
    Given "eth1\s+ethernet\s+connected" is not visible with command "nmcli device"
    Given "state UP" is visible with command "ip a s eth1"
    * "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth1/disable_ipv6"
    * Execute "ip -6 addr add 2001::dead:beef:01/64 dev eth1"
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth1/disable_ipv6"
    Then "inet6 2001::dead:beef:1/64 scope global" is visible with command "ip a s eth1"
    #
    # the connection is assumed externally, meaning it has "addrgenmode none". NM is not
    # interferring with the device, hence there is no IPv6 LL address. Which is a problem,
    # but a problem of the user who takes over the device without setting the addrgenmode
    # to its liking.
    Then "addrgenmode none " is visible with command "ip -d l show eth1"
    Then "inet6 fe80" is not visible with command "ip a s eth1"
    #
    # the assumed connection is created, give just some time for DAD to complete
    Then "eth1\s+ethernet\s+connected\s+eth1" is visible with command "nmcli device" in "5" seconds


    @rhbz1138426
    @restart @add_testeth10
    @ipv6_no_assumed_connection_for_ipv6ll_only
    Scenario: NM - ipv6 - no assumed connection on IPv6LL only device
    * Delete connection "testeth10"
    * Execute "systemctl stop NetworkManager.service"
    * Execute "ip a flush dev eth10; ip l set eth10 down; ip l set eth10 up"
    When "fe80" is visible with command "ip a s eth10" in "5" seconds
    * Execute "systemctl start NetworkManager.service"
    Then "eth10.*eth10" is not visible with command "nmcli con"


    @rhbz1194007
    @ver+=1.8
    @mtu @kill_dnsmasq
    @ipv6_set_ra_announced_mtu
    Scenario: NM - ipv6 - set RA received MTU
    * Finish "ip link add test1 type veth peer name test1p"
    * Finish "ip link add test2 type veth peer name test2p"
    * Finish "brctl addbr vethbr"
    * Finish "brctl setfd vethbr 2"
    * Finish "brctl stp vethbr on"
    * Finish "ip link set dev vethbr up"
    * Finish "ip link set dev test1 up"
    * Finish "ip link set dev test1p up"
    * Finish "ip link set dev test2 up"
    * Finish "ip link set dev test2p up"
    * Finish "brctl addif vethbr test1p test2p"
    * Finish "nmcli connection add type ethernet con-name tc1 ifname test1 autoconnect no"
    * Finish "nmcli connection add type ethernet con-name tc2 ifname test2 autoconnect no mtu 1100 ip6 fd01::1/64"
    * Bring "up" connection "tc2"
    When "test2:connected:tc2" is visible with command "nmcli -t -f DEVICE,STATE,CONNECTION device" in "10" seconds
    * Execute "/usr/sbin/dnsmasq --pid-file=/tmp/dnsmasq.pid --no-resolv --bind-interfaces -i test2 --enable-ra --dhcp-range=::1,::400,constructor:test2,ra-only,64,15s"
    * Bring "up" connection "tc1"
    Then "1280" is visible with command "sysctl net.ipv6.conf.test1.mtu" in "5" seconds


    @rhbz1243958
    @ver+=1.4.0
    @eth0 @mtu
    @nm-online_wait_for_ipv6_to_finish
    Scenario: NM - ipv6 - nm-online wait for non tentative ipv6
    * Finish "ip link add test1 type veth peer name test1p"
    * Finish "ip link set dev test1 up"
    * Finish "ip link set dev test1p up"
    * Finish "nmcli connection add type ethernet con-name tc1 ifname test1 autoconnect no ip4 192.168.99.1/24 ip6 2620:52:0:beef::1/64"
    * Finish "nmcli connection modify tc1 ipv6.may-fail no"
    Then "tentative" is not visible with command "nmcli connection down testeth0 ; nmcli connection down tc1; sleep 2; nmcli connection up id tc1; time nm-online ;ip a s test1|grep 'global tentative'; nmcli connection up testeth0"


    @ver-=1.5
    @rhbz1183015
    @ipv6
    @ipv6_shared_connection_error
    Scenario: NM - ipv6 - shared connection
    * Add a new connection of type "ethernet" and options "con-name ethie ifname eth1 autoconnect no"
    * Execute "nmcli con modify ethie ipv4.method disabled ipv6.method shared"
    Then "Sharing IPv6 connections is not supported yet" is visible with command "nmcli connection up id ethie"


    @rhbz1256822
    @ver+=1.6
    @ipv6 @two_bridged_veths
    @ipv6_shared_connection
    Scenario: nmcli - ipv6 - shared connection
    * Prepare veth pairs "test1,test2" bridged over "vethbr"
    * Add a new connection of type "ethernet" and options "con-name tc2 ifname test2 ipv6.method shared ipv6.addresses 1::1/64"
    * Add a new connection of type "ethernet" and options "con-name tc1 ifname test1"
    Then "inet6 1::1/64" is visible with command "ip a s test2" in "5" seconds
     And "inet6 fe80::" is visible with command "ip a s test2"
     And "inet6 1::" is visible with command "ip a s test1" in "10" seconds
     And "inet6 fe80::" is visible with command "ip a s test1"


    @rhbz1247156
    @ipv6_tunnel_module_removal
    Scenario: NM - ipv6 - ip6_tunnel module removal
    * Execute "modprobe ip6_tunnel"
    When "ip6_tunnel" is visible with command "lsmod |grep ip"
    * Execute "modprobe -r ip6_tunnel"
    Then "ip6_tunnel" is not visible with command "lsmod |grep ip" in "2" seconds


    @rhbz1269520
    @eth @teardown_testveth
    @ipv6_no_activation_schedule_error_in_logs
    Scenario: NM - ipv6 - no activation scheduled error
    * Prepare simulated test "testA" device
    * Add connection type "ethernet" named "ethie" for device "testA"
    * Execute "nmcli connection modify ethie ipv6.may-fail no ipv4.method disabled"
    * Bring "up" connection "ethie"
    * Bring "up" connection "ethie"
    * Bring "up" connection "ethie"
    * Bring "up" connection "ethie"
    Then "activation_source_schedule" is not visible with command "journalctl --since -4m|grep error"


    @rhbz1268866
    @eth @internal_DHCP @teardown_testveth @long
    @ipv6_NM_stable_with_internal_DHCPv6
    Scenario: NM - ipv6 - stable with internal DHCPv6
    * Prepare simulated test "testX" device
    * Add a new connection of type "ethernet" and options "ifname testX con-name ethie autoconnect no"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.method dhcp" in editor
    * Save in editor
    * Quit editor
    * Execute "nmcli con up id ethie" for "100" times

    @ver-=1.6
    @eth @restart @selinux_allow_ifup @teardown_testveth
    @persistent_default_ipv6_gw
    Scenario: NM - ipv6 - persistent default ipv6 gw
    * Add a new connection of type "ethernet" and options "ifname testX con-name ethie"
    * Wait for at least "3" seconds
    * Execute "systemctl stop NetworkManager"
    * Prepare simulated test "testX" device
    * Execute "sysctl net.ipv6.conf.testX.accept_ra_defrtr=1"
    * Execute "sysctl net.ipv6.conf.testX.accept_ra_pinfo=1"
    * Execute "ifup testX"
    * Wait for at least "10" seconds
    * Execute "ip r del 169.254.0.0/16"
    When "default" is visible with command "ip -6 r |grep testX" in "20" seconds
    And "default" is visible with command "ip -6 r |grep testX |grep expire" in "5" seconds
    * Restart NM
    Then "default via fe" is visible with command "ip -6 r |grep testX |grep 'metric 10[0-1]'" in "50" seconds
    And "default via fe" is not visible with command "ip -6 r |grep testX |grep expire" in "5" seconds


    @ver+=1.7 @ver-=1.10.0
    @eth @restart @selinux_allow_ifup @teardown_testveth
    @persistent_default_ipv6_gw
    Scenario: NM - ipv6 - persistent default ipv6 gw
    * Add a new connection of type "ethernet" and options "ifname testX con-name ethie"
    * Wait for at least "3" seconds
    * Execute "systemctl stop NetworkManager"
    * Prepare simulated test "testX" device
    * Execute "sysctl net.ipv6.conf.testX.accept_ra_defrtr=1"
    * Execute "sysctl net.ipv6.conf.testX.accept_ra_pinfo=1"
    * Execute "ifup testX"
    * Wait for at least "10" seconds
    * Execute "ip r del 169.254.0.0/16"
    When "default" is visible with command "ip -6 r |grep testX" in "20" seconds
    And "default" is visible with command "ip -6 r |grep testX |grep expire" in "5" seconds
    * Restart NM
    * Wait for at least "10" seconds
    Then "default via fe" is visible with command "ip -6 r |grep testX |grep 'metric 1024'" in "50" seconds
    And "default via fe" is not visible with command "ip -6 r |grep testX |grep expire" in "5" seconds


    @ver+=1.10.1
    @eth @restart @selinux_allow_ifup @teardown_testveth
    @persistent_default_ipv6_gw
    Scenario: NM - ipv6 - persistent default ipv6 gw
    * Add a new connection of type "ethernet" and options "ifname testX con-name ethie"
    * Wait for at least "3" seconds
    * Execute "systemctl stop NetworkManager"
    * Prepare simulated test "testX" device
    * Execute "sysctl net.ipv6.conf.testX.accept_ra_defrtr=1"
    * Execute "sysctl net.ipv6.conf.testX.accept_ra_pinfo=1"
    * Execute "ifup testX"
    * Wait for at least "20" seconds
    When "default" is visible with command "ip -6 r |grep testX" in "20" seconds
    And "default" is visible with command "ip -6 r |grep testX |grep expire" in "5" seconds
    * Restart NM
    Then "default via fe" is visible with command "ip -6 r |grep testX |grep expire" for full "20" seconds
     And "default via fe" is visible with command "ip -6 r |grep testX |grep 'metric 1024'" in "50" seconds


    @rhbz1274894
    @eth @restart @selinux_allow_ifup @teardown_testveth
    @ver-=1.9.1
    @persistent_ipv6_routes
    Scenario: NM - ipv6 - persistent ipv6 routes
    * Add a new connection of type "ethernet" and options "ifname testX con-name ethie"
    * Wait for at least "3" seconds
    * Execute "systemctl stop NetworkManager"
    * Prepare simulated test "testX" device
    * Execute "sysctl net.ipv6.conf.testX.accept_ra_defrtr=1"
    * Execute "sysctl net.ipv6.conf.testX.accept_ra_pinfo=1"
    * Execute "ifup testX"
    * Wait for at least "10" seconds
    * Execute "ip r del 169.254.0.0/16"
    When "default" is visible with command "ip -6 r |grep testX" in "20" seconds
    And "default" is visible with command "ip -6 r |grep testX |grep expire" in "5" seconds
    And "2620:dead:beaf::\/64" is visible with command "ip -6 r"
    * Restart NM
    * Execute "sleep 20"
    Then "default via fe" is visible with command "ip -6 r |grep testX |grep 'metric 10[0-1]'" in "50" seconds
    And "default via fe" is not visible with command "ip -6 r |grep testX |grep expire" in "5" seconds
    And "2620:dead:beaf::\/64 dev testX\s+proto ra\s+metric 10" is visible with command "ip -6 r"
    And "dev testX\s+proto kernel\s+metric 256\s+expires 11" is visible with command "ip -6 r|grep 2620:dead:beaf" in "60" seconds

    @rhbz1274894
    @eth @restart @selinux_allow_ifup @teardown_testveth
    @ver+=1.9.2
    @persistent_ipv6_routes
    Scenario: NM - ipv6 - persistent ipv6 routes
    * Add a new connection of type "ethernet" and options "ifname testX con-name ethie"
    * Wait for at least "3" seconds
    * Execute "systemctl stop NetworkManager"
    * Prepare simulated test "testX" device
    * Execute "sysctl net.ipv6.conf.testX.accept_ra_defrtr=1"
    * Execute "sysctl net.ipv6.conf.testX.accept_ra_pinfo=1"
    * Execute "ifup testX"
    * Wait for at least "10" seconds
    * Execute "ip r del 169.254.0.0/16"
    When "default" is visible with command "ip -6 r |grep testX" in "20" seconds
    And "default" is visible with command "ip -6 r |grep testX |grep expire" in "5" seconds
    And "2620:dead:beaf::\/64" is visible with command "ip -6 r"
    * Restart NM
    * Execute "sleep 20"
    Then "default via fe" is visible with command "ip -6 r |grep testX |grep 'metric 10[0-1]'" in "50" seconds
    And "default via fe" is not visible with command "ip -6 r |grep testX |grep expire" in "5" seconds
    And "2620:dead:beaf::\/64 dev testX\s+proto ra\s+metric 10" is visible with command "ip -6 r"
    And "dev testX\s+proto kernel\s+metric 100\s+expires 11" is visible with command "ip -6 r|grep 2620:dead:beaf" in "60" seconds


    @rhbz1394500
    @ver+=1.8.0
    @ipv6
    @ipv6_honor_ip_order
    Scenario: NM - ipv6 - honor IP order from configuration upon reapply
    * Add a new connection of type "ethernet" and options "con-name ethie ifname eth2 autoconnect no"
    * Execute "nmcli con modify ethie ipv6.method manual ipv6.addresses 2001:db8:e:10::4/64,2001:db8:e:10::57/64,2001:db8:e:10::30/64"
    * Bring "up" connection "ethie"
    When "2001:db8:e:10::30/64 scope global.*2001:db8:e:10::57/64 scope global.*2001:db8:e:10::4/64" is visible with command "ip a show eth2" in "5" seconds
    * Execute "nmcli con modify ethie ipv6.addresses 2001:db8:e:10::30/64,2001:db8:e:10::57/64,2001:db8:e:10::4/64"
    * Execute "nmcli dev reapply eth2"
    Then "2001:db8:e:10::4/64 scope global.*2001:db8:e:10::57/64 scope global.*2001:db8:e:10::30/64" is visible with command "ip a show eth2"


    @ipv6
    @ipv6_describe
    Scenario: nmcli - ipv6 - describe
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     When Check "\[method\]|\[dns\]|\[dns-search\]|\[addresses\]|\[gateway\]|\[routes\]|\[ignore-auto-routes\]|\[ignore-auto-dns\]|\[never-default\]|\[may-fail\]" are present in describe output for object "ipv6"
     * Submit "goto ipv6" in editor
     Then Check "=== \[method\] ===\s+\[NM property description\]\s+IP configuration method. NMSettingIP4Config and NMSettingIP6Config both support \"auto\", \"manual\", and \"link-local\". See the subclass-specific documentation for other values. In general, for the \"auto\" method, properties such as \"dns\" and \"routes\" specify information that is added on to the information returned from automatic configuration.  The \"ignore-auto-routes\" and \"ignore-auto-dns\" properties modify this behavior. For methods that imply no upstream network, such as \"shared\" or \"link-local\", these properties must be empty." are present in describe output for object "method"

     Then Check "=== \[dns\] ===\s+\[NM property description\]\s+Array of IP addresses of DNS servers.\s+\[nmcli specific description\]\s+Enter a list of IPv6 addresses of DNS servers." are present in describe output for object "dns"
     Then Check "=== \[dns-search\] ===\s+\[NM property description\]\s+Array of DNS search domains." are present in describe output for object "dns-search"
     Then Check "=== \[addresses\] ===\s+\[NM property description\]\s+Array of IP addresses.\s+\[nmcli specific description\]\s+Enter a list of IPv6 addresses formatted as:\s+ip\[/prefix\], ip\[/prefix\],...\s+Missing prefix is regarded as prefix of 128.\s+Example: 2607:f0d0:1002:51::4/64, 1050:0:0:0:5:600:300c:326b" are present in describe output for object "addresses"
     Then Check "=== \[routes\] ===\s+\[NM property description\]\s+Array of IP routes." are present in describe output for object "routes"

    Then Check "=== \[ignore-auto-routes\] ===\s+\[NM property description\]\s+When \"method\" is set to \"auto\" and this property to TRUE, automatically configured routes are ignored and only routes specified in the \"routes\" property, if any, are used." are present in describe output for object "ignore-auto-routes"

    Then Check "=== \[ignore-auto-dns\] ===\s+\[NM property description\]\s+When \"method\" is set to \"auto\" and this property to TRUE, automatically configured nameservers and search domains are ignored and only nameservers and search domains specified in the \"dns\" and \"dns-search\" properties, if any, are used." are present in describe output for object "ignore-auto-dns"

    Then Check "=== \[dhcp-hostname\] ===\s+\[NM property description\]\s+If the \"dhcp-send-hostname\" property is TRUE, then the specified name will be sent to the DHCP server when acquiring a lease." are present in describe output for object "dhcp-hostname"

    Then Check "=== \[never-default\] ===\s+\[NM property description\]\s+If TRUE, this connection will never be the default connection for this IP type, meaning it will never be assigned the default route by NetworkManager." are present in describe output for object "never-default"

    Then Check "=== \[may-fail\] ===\s+\[NM property description\]\s+If TRUE, allow overall network configuration to proceed even if the configuration specified by this property times out.  Note that at least one IP configuration must succeed or overall network configuration will still fail.  For example, in IPv6-only networks, setting this property to TRUE on the NMSettingIP4Config allows the overall network configuration to succeed if IPv4 configuration fails but IPv6 configuration completes successfully." are present in describe output for object "may-fail"


    @rhbz1449873
    @ver+=1.8.0
    @BBB
    @ipv6_keep_external_addresses
    Scenario: NM - ipv6 - keep external addresses
    * Execute "ip link add BBB type dummy"
    * Execute "ip link set dev BBB up"
    * Wait for at least "1" seconds
    * Execute "for i in $(seq 3000); do ip addr add 2017::$i/64 dev BBB; done"
    When "3000" is visible with command "ip addr show dev BBB | grep 'inet6 2017::' -c" in "2" seconds
    Then "3000" is visible with command "ip addr show dev BBB | grep 'inet6 2017::' -c" for full "6" seconds


    @rhbz1457242
    @ver+=1.8.0
    @eth1_disconnect
    @ipv6_keep_external_routes
    Scenario: NM - ipv6 - keep external routes
    * Execute "ip link set eth1 down; ip addr flush eth1; ethtool -A eth1 rx off tx off; ip link set eth1 up"
    * Execute "ip addr add fc00:a::10/64 dev eth1; ip -6 route add fc00:b::10/128 via fc00:a::1"
    When "fc00:b" is visible with command "ip -6 r" in "2" seconds
    Then "fc00:b" is visible with command "ip -6 r" for full "5" seconds


    @rhbz1446367
    @ver+=1.8.0
    @ethernet @teardown_testveth
    @nmcli_general_finish_dad_without_carrier
    Scenario: nmcli - general - finish dad with no carrier
    * Add a new connection of type "ethernet" and options "ifname testX con-name ethernet0 autoconnect no"
    * Prepare simulated veth device "testX" wihout carrier
    * Execute "nmcli con modify ethernet0 ipv4.may-fail no ipv4.method manual ipv4.addresses 1.2.3.4/24"
    * Execute "nmcli con modify ethernet0 ipv4.may-fail yes ipv6.method manual ipv6.addresses 2001::2/128"
    * Bring "up" connection "ethernet0"
    Then "activated" is visible with command "nmcli -g GENERAL.STATE connection show ethernet0" in "5" seconds
     And "1.2.3.4" is visible with command "ip a s testX"
     And "2001::2" is visible with command "ip a s testX"
     And "tentative" is visible with command "ip a s testX" for full "10" seconds


    @rhbz1508001
    @ver+=1.10.0
    @eth @teardown_testveth
    @ipv4_dad_not_preventing_ipv6
    Scenario: NM - ipv6 - add address after ipv4 DAD fail
    * Prepare simulated test "testX" device
    * Add a new connection of type "ethernet" and options "ifname testX con-name ethie ipv4.may-fail yes ipv4.method manual ipv4.addresses 192.168.99.1/24 ipv4.dad-timeout 2001 ipv6.may-fail yes"
    * Reboot
    Then "activated" is visible with command "nmcli -g GENERAL.STATE connection show ethie" in "15" seconds
     And "2620:dead:beaf" is visible with command "ip a s testX"


    @rhbz1470930
    @ver+=1.8.3
    @ethernet @teardown_testveth @netcat
    @ipv6_preserve_cached_routes
    Scenario: NM - ipv6 - preserve cached routes
    * Prepare simulated test "testX" device for IPv6 PMTU discovery
    * Add a new connection of type "ethernet" and options "ifname testX con-name ethernet0 autoconnect no"
    * Execute "nmcli con modify ethernet0 ipv4.method disabled ipv6.method auto"
    * Execute "nmcli con modify ethernet0 ipv6.routes 'fd02::/64 fd01::1'"
    * Execute "ip l set testX up"
    * Bring "up" connection "ethernet0"
    * Execute "dd if=/dev/zero bs=1M count=10 | nc fd02::2 8080"
    Then "mtu 1400" is visible with command "ip route get fd02::2" for full "40" seconds


    @rhbz1368018
    @ver+=1.8
    @eth @restart @kill_dhclient @teardown_testveth
    @persistent_ipv6_after_device_rename
    Scenario: NM - ipv6 - persistent ipv6 after device rename
    * Prepare simulated test "testY" device
    * Add a new connection of type "ethernet" and options "ifname testY con-name ethie"
    * Bring "down" connection "ethie"
    * Bring "up" connection "ethie"
    * Execute "echo -e 'NM_CONTROLLED=no' >> /etc/sysconfig/network-scripts/ifcfg-ethie"
    * Restart NM
    When "0" is visible with command "cat /proc/sys/net/ipv6/conf/testY/disable_ipv6"
    * Rename device "testY" to "festY"
    * Execute "dhclient -1 festY" without waiting for process to finish
    * Wait for at least "5" seconds
    * Execute "kill -9 $(pidof dhclient)"
    When "0" is visible with command "cat /proc/sys/net/ipv6/conf/festY/disable_ipv6"
    * Rename device "festY" to "testY"
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/testY/disable_ipv6"

    @rhbz1462260
    @ver+=1.10.1
    @eth1_disconnect
    @add_ipv6_over_ipv4_configured_ext_device
    Scenario: NM - ipv6 - add ipv6 to external ipv4 configured device
    * Execute "ethtool -A eth1 rx on tx on; ip addr flush eth1; ethtool -A eth1 rx off tx off; ip link set eth1 up"
    * Execute "ip addr add 192.168.100.2/24 dev eth1; ip addr add fe01::1/64 dev eth1"
    Then "fe01::1" is visible with command "ip a show dev eth1" in "5" seconds


    @rhbz1445417
    @ver+=1.10
    @eth @stop_radvd @two_bridged_veths
    @ipv6_multiple_default_routes
    Scenario: NM - ipv6 - multiple default ipv6 routes
    * Prepare veth pairs "test1" bridged over "vethbr"
    * Execute "ip -6 addr add dead:beef::1/64 dev vethbr"
    * Execute "ip -6 addr add beef:dead::1/64 dev test1p"
    * Execute "ip -6 addr add fe80::dead:dead:dead:dead/64 dev test1p"
    * Start radvd server with config from "tmp/radvd.conf"
    * Add a new connection of type "ethernet" and options "con-name ethie ifname test1 ipv6.may-fail no"
    Then "2" is visible with command "ip -6 r |grep test1 | grep default |wc -l" in "40" seconds
