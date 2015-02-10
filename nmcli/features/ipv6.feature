Feature: nmcli: ipv6


    @ipv6_method_static_without_IP
    @ipv6
    Scenario: nmcli - ipv6 - method - static without IP
      * Add connection type "ethernet" named "ethie" for device "eth1"
      * Open editor for connection "ethie"
      * Submit "set ipv6.method static" in editor
      * Save in editor
    Then Error type "ipv6.addresses: this property cannot be empty for" while saving in editor


    @ipv6_method_manual_with_IP
    @ipv6
    Scenario: nmcli - ipv6 - method - manual + IP
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method manual" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4/64, 1050:0:0:0:5:600:300c:326b" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "2607:f0d0:1002:51::4/64" is visible with command "ip a s eth1"
    Then "1050::5:600:300c:326b/128" is visible with command "ip a s eth1"


    @ipv6_method_static_with_IP
    @ipv6
    Scenario: nmcli - ipv6 - method - static + IP
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4, 1050:0:0:0:5:600:300c:326b" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "2607:f0d0:1002:51::4/128" is visible with command "ip a s eth1"
    Then "1050::5:600:300c:326b/128" is visible with command "ip a s eth1"


    @ipv6_addresses_IP_with_netmask
    @ipv6
    Scenario: nmcli - ipv6 - addresses - IP slash netmask
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method manual" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4/63, 1050:0:0:0:5:600:300c:326b/121" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "2607:f0d0:1002:51::4/63" is visible with command "ip a s eth1"
    Then "1050::5:600:300c:326b/121" is visible with command "ip a s eth1"
    # reproducer for 997759
    Then "IPV6_DEFAULTGW" is not visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethie"


    @ipv6_addresses_yes_when_static_switch_asked
    @ipv6
    Scenario: nmcli - ipv6 - addresses - IP and yes to manual question
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv6.addresses dead:beaf::1" in editor
     * Submit "yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     Then "inet6 dead:beaf" is visible with command "ip a s eth10"
     Then "inet6 2620" is not visible with command "ip a s eth10"


    @ipv6_addresses_no_when_static_switch_asked
    @ipv6
    Scenario: nmcli - ipv6 - addresses - IP and no to manual question
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv6.addresses dead:beaf::1" in editor
     * Submit "no" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     Then "inet6 dead:beaf" is visible with command "ip a s eth10"
     Then "inet6 2620" is visible with command "ip a s eth10"


    @ipv6_addresses_invalid_netmask
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - addresses - IP slash invalid netmask
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4/321" in editor
    Then Error type "failed to set 'addresses' property: invalid prefix '321'; <1-128> allowed" while saving in editor


    @ipv6_addresses_IP_with_mask_and_gw
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - addresses - IP slash netmask and gw
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4/64" in editor
     * Submit "set ipv6.gateway 2607:f0d0:1002:51::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "2607:f0d0:1002:51::4/64" is visible with command "ip a s eth1"
    Then "default via 2607:f0d0:1002:51::1 dev eth1  proto static  metric" is visible with command "ip -6 route"


    @ipv6_addresses_set_several_IPv6s_with_masks_and_gws
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - addresses - several IPs slash netmask and gw
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses fc01::1:5/68, fb01::1:6/112" in editor
     * Submit "set ipv6.addresses fc02::1:21/96" in editor
     * Submit "set ipv6.gateway fc01::1:1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "fc02::1:21/96" is visible with command "ip a s eth1"
    Then "fc01::1:5/68" is visible with command "ip a s eth1"
    Then "fb01::1:6/112" is visible with command "ip a s eth1"
    Then "default via fc01::1:1 dev eth1" is visible with command "ip -6 route"


    @ipv6_addresses_delete_IP_moving_method_back_to_auto
    @ipv6
    Scenario: nmcli - ipv6 - addresses - delete IP and set method back to auto
     * Add connection type "ethernet" named "ethie" for device "eth10"
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
    Then "fc01::1:5/68" is not visible with command "ip a s eth10"
    Then "default via fc01::1:1 dev eth1" is not visible with command "ip -6 route"
    Then "2620:52:0:" is visible with command "ip a s eth10"


    @ipv6_routes_set_basic_route
    @ipv6_2
    @eth0
    Scenario: nmcli - ipv6 - routes - set basic route
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2000::2/126" in editor
     * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
     * Save in editor
     * Quit editor
     * Add connection type "ethernet" named "ethie2" for device "eth2"
     * Open editor for connection "ethie2"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.routes 3030::1/128 2001::2 1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Bring "up" connection "ethie2"
    Then "1010::1 via 2000::1 dev eth1  proto static  metric 1" is visible with command "ip -6 route"
    Then "2000::/126 dev eth1  proto kernel  metric 256" is visible with command "ip -6 route"
    Then "2001::/126 dev eth2  proto kernel  metric 256" is visible with command "ip -6 route"
    Then "3030::1 via 2001::2 dev eth2  proto static  metric 1" is visible with command "ip -6 route"


    @ipv6_routes_remove_basic_route
    @ipv6_2
    @eth0
    Scenario: nmcli - ipv6 - routes - remove basic route
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2000::2/126" in editor
     * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
     * Save in editor
     * Quit editor
     * Add connection type "ethernet" named "ethie2" for device "eth2"
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
    Then "1010::1 via 2000::1 dev eth1  proto static  metric 1" is not visible with command "ip -6 route"
    Then "2000::/126 dev eth1  proto kernel  metric 256" is visible with command "ip -6 route"
    Then "2001::/126 dev eth2  proto kernel  metric 256" is visible with command "ip -6 route"
    Then "3030::1 via 2001::2 dev eth2  proto static  metric 1" is not visible with command "ip -6 route"


    @ipv6_routes_device_route
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - routes - set device route
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.gateway 4000::1" in editor
     * Submit "set ipv6.routes 1010::1/128 :: 3, 3030::1/128 2001::2 2 " in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "default via 4000::1 dev eth1  proto static  metric" is visible with command "ip -6 route"
    Then "3030::1 via 2001::2 dev eth1  proto static  metric 2" is visible with command "ip -6 route"
    Then "2001::/126 dev eth1  proto kernel  metric 256" is visible with command "ip -6 route"
    Then "1010::1 dev eth1  proto static  metric 3" is visible with command "ip -6 route"


    @ipv6_correct_slaac_setting
    @ipv6
    @eth0
    Scenario: NM - ipv6 - correct slaac setting
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Bring "up" connection "ethie"
    Then Check device route and prefix for "eth10"


    @ipv6_limited_router_solicitation
    @ipv6
    @eth0
    Scenario: NM - ipv6 - limited router solicitation
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Bring "up" connection "ethie"
     * Finish "sudo tshark -i eth10 -Y frame.len==62 -V -x -a duration:120 > /tmp/solicitation.txt"
    Then Check solicitation for "eth10" in "/tmp/solicitation.txt"


    @ipv6_block_just_routing_RA
    @ipv6
    # reproducer for 1068673
    Scenario: NM - ipv6 - block just routing RA
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Bring "up" connection "ethie"
    Then "1" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/accept_ra"
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/accept_ra_defrtr"
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/accept_ra_rtr_pref"
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/accept_ra_pinfo"


    @ipv6_routes_invalid_IP
    @ipv6
    Scenario: nmcli - ipv6 - routes - set invalid route - non IP
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.gateway 4000::1" in editor
     * Submit "set ipv6.routes non:rout:set:up" in editor
    Then Error type "failed to set 'routes' property:" while saving in editor


    @ipv6_routes_without_gw
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - routes - set invalid route - missing gw
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.gateway 4000::1" in editor
     * Submit "set ipv6.routes 1010::1/128" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "default via 4000::1 dev eth1  proto static  metric" is visible with command "ip -6 route"
    Then "2001::/126 dev eth1  proto kernel  metric 256" is visible with command "ip -6 route"
    Then "1010::1 dev eth1  proto static  metric" is visible with command "ip -6 route"


    @ipv6_dns_manual_IP_with_manual_dns
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - dns - method static + IP + dns
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126" in editor
     * Submit "set ipv6.gateway 4000::1" in editor
     * Submit "set ipv6.dns 4000::1, 5000::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "nameserver 4000::1" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 5000::1" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 10." is visible with command "cat /etc/resolv.conf"

#FIXME: this need some tuning as there may be some auto obtained ipv6 dns VVVV

    @ipv6_dns_auto_with_more_manually_set
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - dns - method auto + dns
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.dns 4000::1, 5000::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "nameserver 4000::1" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 5000::1" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 192.168.100.1" is visible with command "cat /etc/resolv.conf"


    @ipv6_dns_ignore-auto-dns_with_manually_set_dns
    @ipv6
    Scenario: nmcli - ipv6 - dns - method auto + dns + ignore automaticaly obtained
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.ignore-auto-dns yes" in editor
     * Submit "set ipv6.dns 4000::1, 5000::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "nameserver 4000::1" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 5000::1" is visible with command "cat /etc/resolv.conf"


    @ipv6_dns_add_more_when_already_have_some
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - dns - add dns when one already set
     * Add connection type "ethernet" named "ethie" for device "eth1"
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
    Then "nameserver 4000::1" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 5000::1" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 2000::1" is visible with command "cat /etc/resolv.conf"


    @ipv6_dns_remove_manually_set
    @ipv6
    @eth0
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


    @ipv6_dns-search_set
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - dns-search - add dns-search
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv4.ignore-auto-dns yes" in editor
     * Submit "set ipv6.dns-search redhat.com" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "redhat.com" is visible with command "cat /etc/resolv.conf"


    @ipv6_dns-search_remove
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - dns-search - remove dns-search
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv4.ignore-auto-dns yes" in editor
     * Submit "set ipv6.dns-search redhat.com" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Open editor for connection "ethie"
     * Submit "set ipv6.dns-search" in editor
     * Enter in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then " redhat.com" is not visible with command "cat /etc/resolv.conf"


    @ipv6_ignore-auto-dns_set
    @NM
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - ignore auto obtained dns
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv4.ignore-auto-dns yes" in editor
     * Submit "set ipv6.ignore-auto-dns yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then " redhat.com" is not visible with command "cat /etc/resolv.conf"
    Then "virtual" is not visible with command "cat /etc/resolv.conf"
    Then "No nameservers found" is visible with command "cat /etc/resolv.conf"


    @ipv6_ignore-auto-dns_set-generic
    @NM
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - ignore auto obtained dns - generic
     * Add connection type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv4.ignore-auto-dns yes" in editor
     * Submit "set ipv6.ignore-auto-dns yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then " redhat.com" is not visible with command "cat /etc/resolv.conf"
    Then "virtual" is not visible with command "cat /etc/resolv.conf"
    Then "nameserver " is not visible with command "cat /etc/resolv.conf"


    @ipv6_method_link-local
    @ipv6
    Scenario: nmcli - ipv6 - method - link-local
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method link-local" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "inet6 fe80::" is visible with command "ip -6 a s eth1"
    Then "scope global" is not visible with command "ip -6 a s eth1"


    @ipv6_may_fail_set_true
    @ipv6
    Scenario: nmcli - ipv6 - may-fail - set true
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method dhcp" in editor
     * Submit "set ipv6.may-fail yes" in editor
     * Save in editor
     * Quit editor
    Then Bring "up" connection "ethie"


    @ipv6_method_ignored
    @ipv6
    Scenario: nmcli - ipv6 - method - ignored
     * Add connection type "ethernet" named "ethie" for device "eth10"
     Then Bring "up" connection "ethie"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method static" in editor
     * Submit "set ipv4.addresses 192.168.122.253/24" in editor
     * Submit "set ipv6.method ignore" in editor
     * Save in editor
     * Quit editor
    Then Bring "up" connection "ethie"
    # VVV commented out because of fe80 is still on by kernel very likely
    # Then "scope link" is not visible with command "ip -6 a s eth10"
    Then "scope global" is not visible with command "ip a -6 s eth10"
    # reproducer for 1004255
    Then Bring "down" connection "ethie"
    Then "eth10 " is not visible with command "ip -6 route |grep -v fe80"


    @ipv6_never-default_set_true
    @ipv6
    #@eth0
    Scenario: nmcli - ipv6 - never-default - set
     * Add connection type "ethernet" named "ethie" for device "eth2"
     * Open editor for connection "ethie"
     * Submit "set ipv6.never-default yes " in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "testeth10"
     * Bring "up" connection "ethie"
    Then "default via " is not visible with command "ip -6 route |grep eth2"


    @ipv6_never-default_remove
    @ipv6
    #@eth0
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
    Then "default via " is not visible with command "ip -6 route |grep eth2"


    @ipv6_dhcp-hostname_set
    @veth
    @profie
    Scenario: nmcli - ipv6 - dhcp-hostname - set dhcp-hostname
    * Add connection type "ethernet" named "profie" for device "eth10"
    * Run child "sudo tshark -i eth10 -f 'port 546' -V -x > /tmp/ipv6-hostname.log"
    * Finish "sleep 2"
    * Open editor for connection "profie"
    * Submit "set ipv6.may-fail true" in editor
    * Submit "set ipv6.method dhcp" in editor
    * Submit "set ipv6.dhcp-hostname RHX" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "profie"
    * Finish "sleep 5"
    * Run child "sudo kill -9 $(pidof tshark)"
    #Then "walderon" is visible with command "sudo cat /var/lib/NetworkManager/dhclient6-eth10.conf"
    Then "RHX" is visible with command "grep RHX /tmp/ipv6-hostname.log"


    @ipv6_dhcp-hostname_remove
    @veth
    @ipv4
    Scenario: nmcli - ipv6 - dhcp-hostname - remove dhcp-hostname
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.dhcp-hostname RHX" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Run child "sudo tshark -i eth10 -f 'port 546' -V -x > /tmp/tshark.log"
    * Open editor for connection "ethie"
    * Submit "set ipv6.dhcp-hostname" in editor
    * Enter in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Finish "sleep 5"
    * Run child "sudo kill -9 $(pidof tshark)"
    Then "RHX" is not visible with command "cat /tmp/tshark.log"


    @ipv6_ip6-privacy_0
    @ipv6
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
    * Finish "sleep 2"
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/use_tempaddr"
    Then "global temporary dynamic" is not visible with command "ip a s eth10"


    @ipv6_ip6-privacy_1
    @ipv6
    Scenario: nmcli - ipv6 - ip6_privacy - 1

    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.ip6-privacy 1" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Finish "sleep 2"
    Then "1" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/use_tempaddr"
    Then Global temporary ip is not based on mac of device "eth10"


    @ipv6_ip6-privacy_2
    @ipv6
    Scenario: nmcli - ipv6 - ip6_privacy - 2
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.ip6-privacy 2" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Finish "sleep 2"
    Then "2" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/use_tempaddr"
    Then Global temporary ip is not based on mac of device "eth10"



    @ipv6_ip6-privacy_incorrect_value
    @ipv6
    Scenario: nmcli - ipv6 - ip6_privacy - incorrect value
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.ip6-privacy 3" in editor
    Then Error type "failed to set 'ip6-privacy' property: '3' is not valid\; use 0, 1, or 2" while saving in editor
    * Submit "set ipv6.ip6-privacy RHX" in editor
    Then Error type "failed to set 'ip6-privacy' property: 'RHX' is not a number" while saving in editor


    @ipv6_take_manually_created_ifcfg
    @veth
    @ipv6
    @rhbz1073824
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
    @ipv6_lifetime_set_from_network
    @scapy
    Scenario: NM - ipv6 - set lifetime from network
    * Finish "ip link add test10 type veth peer name test11"
    * Finish "nmcli c add type ethernet ifname test10"
    * Finish "nmcli c add type ethernet ifname test11"
    * Execute "nmcli con modify ethernet-test10 ipv4.method disabled ipv6.method auto"
    * Execute "nmcli con modify ethernet-test11 ipv4.method disabled ipv6.method auto"
    * Finish "ip link set dev test10 up"
    * Finish "ip link set dev test11 up"
    * Execute "sleep 1"
    When "ethernet-test10" is visible with command "nmcli con sh -a"
    When "ethernet-test11" is visible with command "nmcli con sh -a"
    * Send lifetime scapy packet
    Then Lifetimes are slightly smaller than "3600" and "1800" for device "test11"



    @rhbz1170530
    @add_testeth10
    @ipv6_keep_connectivity_on_assuming_connection_profile
    @ipv6
    Scenario: NM - ipv6 - keep connectivity on assuming connection profile
    * Add a new connection of type "ethernet" and options "con-name ethie ifname eth10 autoconnect no"
    * Bring up connection "ethie"
    * Wait for at least "10" seconds
    Then Check ipv6 connectivity is stable on assuming connection profile "ethie" for device "eth10"


    @rhbz1083133
    @rhbz1098319
    @rhbz1127718
    @veth
    @ipv6_add_static_address_manually_not_active
    @eth1_disconnect
    Scenario: NM - ipv6 - add a static address manually to non-active interface
    Given "testeth1" is visible with command "nmcli connection"
    Given "eth1\s+ethernet\s+connected" is not visible with command "nmcli device"
    Given "state UP" is visible with command "ip a s eth1"
    * "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth1/disable_ipv6"
    * Execute "ip -6 addr add 2001::dead:beef:01/64 dev eth1"
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth1/disable_ipv6"
    Then "inet6 2001::dead:beef:1/64 scope global" is visible with command "ip a s eth1"
    Then "inet6 fe80" is visible with command "ip a s eth1"
    # the assumed connection is created
    Then "eth1\s+ethernet\s+connected\s+eth1" is visible with command "nmcli device"


    @ipv6_describe
    @ipv6
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


