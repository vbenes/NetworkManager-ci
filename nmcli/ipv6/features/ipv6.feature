Feature: nmcli: ipv6


    @ipv6_method_static_without_IP
    @ipv6
    Scenario: nmcli - ipv6 - method - static without IP
      * Add connection for a type "ethernet" named "ethie" for device "eth1"
      * Open editor for connection "ethie"
      * Submit "set ipv6.method static" in editor
      * Save in editor
    Then Error type "connection verification failed: ipv6.addresses: property is missing" while saving in editor


    @ipv6_method_manual_with_IP
    @ipv6
    Scenario: nmcli - ipv6 - method - manual + IP
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
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
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
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
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method manual" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4/63, 1050:0:0:0:5:600:300c:326b/121" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "2607:f0d0:1002:51::4/63" is visible with command "ip a s eth1"
    Then "1050::5:600:300c:326b/121" is visible with command "ip a s eth1"


    @ipv6_addresses_yes_when_static_switch_asked
    @ipv6
    Scenario: nmcli - ipv6 - addresses - IP and yes to manual question
     * Add connection for a type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv6.addresses dead:beaf::1" in editor
     * Submit "yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     Then "inet6 dead:beaf" is visible with command "ip a s eth10"
     Then "inet6 2001" is not visible with command "ip a s eth10"


    @ipv6_addresses_no_when_static_switch_asked
    @ipv6
    Scenario: nmcli - ipv6 - addresses - IP and no to manual question
     * Add connection for a type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv6.addresses dead:beaf::1" in editor
     * Submit "no" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     Then "inet6 dead:beaf" is visible with command "ip a s eth10"
     Then "inet6 2001" is visible with command "ip a s eth10"

    @ipv6_addresses_invalid_netmask
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - addresses - IP slash invalid netmask
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4/321" in editor
    Then Error type "failed to set 'addresses' property: invalid prefix '321'; <1-128> allowed" while saving in editor


    @ipv6_addresses_IP_with_mask_and_gw
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - addresses - IP slash netmask and gw
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2607:f0d0:1002:51::4/64 2607:f0d0:1002:51::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "2607:f0d0:1002:51::4/64" is visible with command "ip a s eth1"
    Then "default via 2607:f0d0:1002:51::1 dev eth1  proto static  metric 1024" is visible with command "ip -6 route"


    @ipv6_addresses_set_several_IPv6s_with_masks_and_gws
    @ipv6
    @eth0
    Scenario: nmcli - ipv6 - addresses - several IPs slash netmask and gw
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses fc01::1:5/68 fc01::1:1, fb01::1:6/112 fb02::1:1" in editor
     * Submit "set ipv6.addresses fc02::1:21/96" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "fc02::1:21/96" is visible with command "ip a s eth1"
    Then "fc01::1:5/68" is visible with command "ip a s eth1"
    Then "fb01::1:6/112" is visible with command "ip a s eth1"
    Then "fc01::/68 dev eth1" is visible with command "ip -6 route"
    Then "fc02::/96 dev eth1" is visible with command "ip -6 route"
    Then "fb01::1:0/112 dev eth1" is visible with command "ip -6 route"
    Then "default via fc01::1:1 dev eth1" is visible with command "ip -6 route"


    @ipv6_addresses_delete_IP_moving_method_back_to_auto
    @ipv6
    Scenario: nmcli - ipv6 - addresses - delete IP and set method back to auto
     * Add connection for a type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses fc01::1:5/68 fc01::1:1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
     * Open editor for connection "ethie"
     * Submit "set ipv6.addresses" in editor
     * Enter in editor
     * Submit "set ipv6.method auto" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "fc01::1:5/68" is not visible with command "ip a s eth10"
    Then "default via fc01::1:1 dev eth1" is not visible with command "ip -6 route"
    Then "2001:db8:1:0:5054" is visible with command "ip a s eth10"


    @ipv6_routes_set_basic_route
    @eth0
    @ipv6_2
    Scenario: nmcli - ipv6 - routes - set basic route
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2000::2/126" in editor
     * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
     * Save in editor
     * Quit editor
     * Add connection for a type "ethernet" named "ethie2" for device "eth2"
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
    @eth0
    @ipv6_2
    Scenario: nmcli - ipv6 - routes - remove basic route
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2000::2/126" in editor
     * Submit "set ipv6.routes 1010::1/128 2000::1 1" in editor
     * Save in editor
     * Quit editor
     * Add connection for a type "ethernet" named "ethie2" for device "eth2"
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
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - routes - set device route
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126 4000::1" in editor
     * Submit "set ipv6.routes 1010::1/128 :: 3, 3030::1/128 2001::2 2 " in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "default via 4000::1 dev eth1  proto static  metric 1024" is visible with command "ip -6 route"
    Then "3030::1 via 2001::2 dev eth1  proto static  metric 2" is visible with command "ip -6 route"
    Then "2001::/126 dev eth1  proto kernel  metric 256" is visible with command "ip -6 route"
    Then "1010::1 dev eth1  proto static  metric 3" is visible with command "ip -6 route"


    @ipv6_routes_invalid_IP
    @ipv6
    Scenario: nmcli - ipv6 - routes - set invalid route - non IP
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126 4000::1" in editor
     * Submit "set ipv6.routes non:rout:set:up" in editor
    Then Error type "failed to set 'routes' property: 'non:rout:set:up' is not valid \(use \<dest IP\>\/prefix \<next-hop IP\> \[metric\]\)" while saving in editor


    @ipv6_routes_without_gw
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - routes - set invalid route - missing gw
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126 4000::1" in editor
     * Submit "set ipv6.routes 1010::1/128" in editor
    Then Error type "failed to set 'routes' property: '1010::1\/128" while saving in editor


    @ipv6_dns_manual_IP_with_manual_dns
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - dns - method static + IP + dns
     * Add connection for a type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126 4000::1" in editor
     * Submit "set ipv6.dns 4000::1, 5000::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "nameserver 4000::1\s+nameserver 5000::1" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 10." is visible with command "cat /etc/resolv.conf"

#FIXME: this need some tuning as there may be some auto obtained ipv6 dns VVVV

    @ipv6_dns_auto_with_more_manually_set
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - dns - method auto + dns
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
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
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.ignore-auto-dns yes" in editor
     * Submit "set ipv6.dns 4000::1, 5000::1" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "nameserver 4000::1" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 5000::1" is visible with command "cat /etc/resolv.conf"


    @ipv6_dns_add_more_when_already_have_some
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - dns - add dns when one already set
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method static" in editor
     * Submit "set ipv6.addresses 2001::1/126 4000::1" in editor
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
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - dns - method auto then delete all dns
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
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
#    Then "nameserver 10." is visible with command "cat /etc/resolv.conf"


    @ipv6_dns-search_set
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - dns-search - add dns-search
     * Add connection for a type "ethernet" named "ethie" for device "eth10"
     * Open editor for connection "ethie"
     * Submit "set ipv4.method disabled" in editor
     * Submit "set ipv4.ignore-auto-dns yes" in editor
     * Submit "set ipv6.dns-search redhat.com" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "ethie"
    Then "redhat.com" is visible with command "cat /etc/resolv.conf"
    #Then Ping6 "ns1.app.eng.bos"
    #Then Ping6 "ns1.app.eng.bos.redhat.com"


    @ipv6_dns-search_remove
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - dns-search - remove dns-search
     * Add connection for a type "ethernet" named "ethie" for device "eth10"
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
    #Then Unable to ping6 "ns1.app.eng.bos"


    @ipv6_ignore-auto-dns_set
    @NM
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - ignore auto obtained dns
     * Add connection for a type "ethernet" named "ethie" for device "eth10"
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


    @ipv6_method_link-local
    @ipv6
    Scenario: nmcli - ipv6 - method - link-local
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
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
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method dhcp" in editor
     * Submit "set ipv6.may-fail yes" in editor
     * Save in editor
     * Quit editor
    Then Bring "up" connection "ethie"


    @ipv6_method_ignored
    @ipv6
    Scenario: nmcli - ipv6 - method - ignored
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.method ignore" in editor
     * Save in editor
     * Quit editor
    Then Bring "up" connection "ethie"
    Then "scope link" is visible with command "ip -6 a s eth1"
    Then "scope global" is not visible with command "ip a -6 s eth1"


    @ipv6_never-default_set_true
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - never-default - set
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     * Submit "set ipv6.never-default yes " in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "eth0"
     * Bring "up" connection "ethie"
    Then "default via " is not visible with command "ip -6 route |grep eth1"


    @ipv6_never-default_remove
    @eth0
    @ipv6
    Scenario: nmcli - ipv6 - never-default - remove
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
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
     * Bring "up" connection "eth0"
     * Bring "up" connection "ethie"
    Then "default via " is not visible with command "ip -6 route |grep eth1"


    @ipv6_dhcp-hostname_set
    @profie
    Scenario: nmcli - ipv6 - dhcp-hostname - set dhcp-hostname
    * Add connection for a type "ethernet" named "profie" for device "eth10"
    * Run child "sudo tshark -i eth10 -f 'port 546' -V -x > /tmp/ipv6-hostname.log"
    * Open editor for connection "profie"
#    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.may-fail true" in editor
    * Submit "set ipv6.method dhcp" in editor
    * Submit "set ipv6.dhcp-hostname walderon" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "profie"
    * Run child "sudo kill -9 $(pidof tshark)"
    Then "walderon" is visible with command "sudo cat /var/lib/NetworkManager/dhclient6-eth10.conf"
    Then "walderon" is visible with command "grep walderon /tmp/ipv6-hostname.log"


    @ipv6_dhcp-hostname_remove
    @ipv4
    Scenario: nmcli - ipv6 - dhcp-hostname - remove dhcp-hostname
    * Add connection for a type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.dhcp-hostname walderon" in editor
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
    * Run child "sudo kill -9 $(pidof tshark)"
    Then "walderon" is not visible with command "cat /tmp/tshark.log"


    @ipv6_ip6-privacy_0
    @ipv6
    Scenario: nmcli - ipv6 - ip6_privacy - 0
    * Add connection for a type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.ip6-privacy 0" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "0" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/use_tempaddr"


    @ipv6_ip6-privacy_1
    @ipv6
    Scenario: nmcli - ipv6 - ip6_privacy - 1
    * Add connection for a type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.ip6-privacy 1" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "1" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/use_tempaddr"


    @ipv6_ip6-privacy_2
    @ipv6
    Scenario: nmcli - ipv6 - ip6_privacy - 2
    * Add connection for a type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.ip6-privacy 2" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "2" is visible with command "cat /proc/sys/net/ipv6/conf/eth10/use_tempaddr"


    @ipv6_ip6-privacy_incorrect_value
    @ipv6
    Scenario: nmcli - ipv6 - ip6_privacy - incorrect value
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.ip6-privacy 3" in editor
    Then Error type "failed to set 'ip6-privacy' property: '3' is not valid\; use 0, 1, or 2" while saving in editor
    * Submit "set ipv6.ip6-privacy walderoon" in editor
    Then Error type "failed to set 'ip6-privacy' property: 'walderoon' is not a number" while saving in editor


    @ipv6_describe
    @ipv6
    Scenario: nmcli - ipv6 - describe
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
     When Check "\[method\]|\[dhcp-hostname\]|\[dns\]|\[dns-search\]|\[addresses\]|\[routes\]|\[ignore-auto-routes\]|\[ignore-auto-dns\]|\[never-default\]|\[may-fail\]" are present in describe output for object "ipv6"
     * Submit "goto ipv6" in editor
     Then Check "=== \[method\] ===\s+\[NM property description\]\s+IPv6 configuration method.  If 'auto' is specified then the appropriate automatic method \(PPP, router advertisement, etc\) is used for the device and most other properties can be left unset.  To force the use of DHCP only, specify 'dhcp'; this method is only valid for ethernet-based hardware.  If 'link-local' is specified, then an IPv6 link-local address will be assigned to the interface.  If 'manual' is specified, static IP addressing is used and at least one IP address must be given in  the 'addresses' property.  If 'ignore' is specified, IPv6 configuration is not done. This property must be set.  Note: the 'shared' method is not yet supported." are present in describe output for object "method"
     Then Check "=== \[dns\] ===\s+\[NM property description\]\s+Array of DNS servers, where each member of the array is a byte array containing the IPv6 address of the DNS server \(in network byte order\). For the 'auto' method, these DNS servers are appended to those \(if any\) returned by automatic configuration.  DNS servers cannot be used with the 'shared' or 'link-local' methods as there is no usptream network.  In all other methods, these DNS servers are used as the only DNS servers for this connection.\s+\[nmcli specific description\]\s+Enter a list of IPv6 addresses of DNS servers.  If the IPv6 configuration method is 'auto' these DNS servers are appended to those \(if any\) returned by automatic configuration.  DNS servers cannot be used with the 'shared' or 'link-local' IPv6 configuration methods, as there is no upstream network. In all other IPv6 configuration methods, these DNS servers are used as the only DNS servers for this connection.\s+Example: 2607:f0d0:1002:51::4, 2607:f0d0:1002:51::1" are present in describe output for object "dns"
     Then Check "=== \[dns-search\] ===\s+\[NM property description\]\s+List of DNS search domains.  For the 'auto' method, these search domains are appended to those returned by automatic configuration. Search domains cannot be used with the 'shared' or 'link-local' methods as there is no upstream network.  In all other methods, these search domains are used as the only search domains for this connection." are present in describe output for object "dns-search"
     Then Check "=== \[addresses\] ===\s+\[NM property description\]\s+Array of IPv6 address structures.\s+Each IPv6 address structure is composed of 3 members, the first being a byte array containing the IPv6 address \(network byte order\), the second a 32-bit integer containing the IPv6 address prefix, and the third a byte array containing the IPv6 address \(network byte order\) of the gateway associated with this address, if any. If no gateway is given, the third element should be given as all zeros.  For the 'auto' method, given IP addresses are appended to those returned by automatic configuration.  Addresses cannot be used with the 'shared' or 'link-local' methods as the interface is automatically assigned an address with these methods.\s+\[nmcli specific description\]\s+Enter a list of IPv6 addresses formatted as:\s+ip\[\/prefix\] \[gateway\], ip\[\/prefix\] \[gateway\],...\s+Missing prefix is regarded as prefix of 128.\s+Example: 2607:f0d0:1002:51::4\/64 2607:f0d0:1002:51::1, 1050:0:0:0:5:600:300c:326b" are present in describe output for object "addresses"
     Then Check "=== \[routes\] ===\s+\[NM property description\]\s+Array of IPv6 route structures.\s+Each IPv6 route structure is composed of 4 members; the first being the destination IPv6 network or address \(network byte order\) as a byte array, the second the destination network or address IPv6 prefix, the third being the next-hop IPv6 address \(network byte order\) if any, and the fourth being the route metric. For the 'auto' method, given IP routes are appended to those returned by automatic configuration.  Routes cannot be used with the 'shared' or 'link-local' methods because there is no upstream network.\s+\[nmcli specific description\]\s+Enter a list of IPv6 routes formatted as:\s+ip\/\[prefix\] next-hop \[metric\],...\s+Missing prefix is regarded as a prefix of 128.\s+Missing metric is regarded as a metric of 0.\s+Example: 2001:db8:beef:2::\/64 2001:db8:beef::2, 2001:db8:beef:3::\/64 2001:db8:beef::3 2" are present in describe output for object "routes"
     Then Check "=== \[ignore-auto-routes\] ===\s+\[NM property description\]\s+When the method is set to 'auto' or 'dhcp' and this property is set to TRUE, automatically configured routes are ignored and only routes specified in the 'routes' property, if any, are used." are present in describe output for object "ignore-auto-routes"
     Then Check "=== \[ignore-auto-dns\] ===\s+\[NM property description\]\s+When the method is set to 'auto' or 'dhcp' and this property is set to TRUE, automatically configured nameservers and search domains are ignored and only nameservers and search domains specified in the 'dns' and 'dns-search' properties, if any, are used." are present in describe output for object "ignore-auto-dns"
     Then Check "=== \[dhcp-hostname\] ===\s+\[NM property description\]\s+The specified name will be sent to the DHCP server when acquiring a lease." are present in describe output for object "dhcp-hostname"
     Then Check "=== \[never-default\] ===\s+\[NM property description\]\s+If TRUE, this connection will never be the default IPv6 connection, meaning it will never be assigned the default IPv6 route by NetworkManager." are present in describe output for object "never-default"
     Then Check "=== \[may-fail\] ===\s+\[NM property description\]\s+If TRUE, allow overall network configuration to proceed even if IPv6 configuration times out. Note that at least one IP configuration must succeed or overall network configuration will still fail.  For example, in IPv4-only networks, setting this property to TRUE allows the overall network configuration to succeed if IPv6 configuration fails but IPv4 configuration completes successfully." are present in describe output for object "may-fail"

