Feature: nmcli: ipv4


    @testcase_303647
    @ipv4
    Scenario: nmcli - ipv4 - method - static without IP
     * Add connection type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Save in editor
    Then Error type "connection verification failed: ipv4.addresses:" while saving in editor


    @testcase_303648
    @ipv4
    Scenario: nmcli - ipv4 - method - manual + IP
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 192.168.122.253" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "192.168.122.253/32" is visible with command "ip a s eth1"
    #VVV coverage for https://bugzilla.redhat.com/show_bug.cgi?id=979288
    Then "dhclient-eth1.pid" is not visible with command "ps aux|grep dhclient"


    @testcase_303649
    @ipv4
    Scenario: nmcli - ipv4 - method - static + IP
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.253" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "192.168.122.253/32" is visible with command "ip a s eth1"


    @testcase_303650
    @ipv4
    Scenario: nmcli - ipv4 - addresses - IP allowing manual when asked
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.addresses 192.168.122.253" in editor
    * Submit "yes" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "192.168.122.253/32" is visible with command "ip a s eth1"


    @testcase_303651
    @ipv4
    Scenario: nmcli - ipv4 - addresses - IP slash netmask
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.253/24" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    #reproducer for 1034900
    Then "192.168.122.253/24 brd 192.168.122.255" is visible with command "ip a s eth1"


    @ipv4_change_in_address
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - addresses - change in address
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 1.1.1.99/24" in editor
    * Submit "set ipv4.gateway 1.1.1.1" in editor
    * Save in editor
    * Submit "goto ipv4" in editor
    * Submit "goto gateway" in editor
    * Submit "change" in editor
    * Backspace in editor
    * Submit "4" in editor
    * Submit "back" in editor
    * Submit "back" in editor
    * Save in editor
    * Submit "print" in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "1.1.1.99/24 brd 1.1.1.255" is visible with command "ip a s eth1"
    Then "default via 1.1.1.4" is visible with command "ip route"
    Then "default via 1.1.1.1" is not visible with command "ip route"


#    @testcase_hash
#    @ipv4
#    Scenario: nmcli - ipv4 - addresses - IP slash IP netmask
#    * Add connection type "ethernet" named "ethie" for device "eth1"
#    * Open editor for connection "ethie"
#    * Submit "set ipv4.method static" in editor
#    * Submit "set ipv4.addresses 192.168.122.253/255.255.255.0" in editor
#    * Save in editor
#    * Quit editor
#    * Bring "up" connection "ethie"
#    Then "192.168.122.253/24" is visible with command "ip a s eth1"


    @testcase_303652
    @ipv4
    Scenario: nmcli - ipv4 - addresses - IP slash invalid netmask
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.253/192.168.122.1" in editor
    Then Error type "failed to set 'addresses' property: invalid prefix '192.168.122.1'; <1-32> allowed" while saving in editor


    @ipv4_take_manually_created_ifcfg_with_ip
    @veth
    @ipv4
    # covering https://bugzilla.redhat.com/show_bug.cgi?id=1073824
    Scenario: nmcli - ipv4 - use manually created ipv4 profile
    * Append "DEVICE='eth10'" to ifcfg file "ethie"
    * Append "ONBOOT=yes" to ifcfg file "ethie"
    * Append "NETBOOT=yes" to ifcfg file "ethie"
    * Append "UUID='aa17d688-a38d-481d-888d-6d69cca781b8'" to ifcfg file "ethie"
    * Append "BOOTPROTO=none" to ifcfg file "ethie"
    #* Append "HWADDR='52:54:00:32:77:59'" to ifcfg file "ethie"
    * Append "TYPE=Ethernet" to ifcfg file "ethie"
    * Append "NAME='ethie'" to ifcfg file "ethie"
    * Append "IPADDR='10.0.0.2'" to ifcfg file "ethie"
    * Append "PREFIX='24'" to ifcfg file "ethie"
    * Append "GATEWAY='10.0.0.1'" to ifcfg file "ethie"
    * Restart NM
    Then "aa17d688-a38d-481d-888d-6d69cca781b8" is visible with command "nmcli -f UUID connection show -a"


    @testcase_303653
    @ipv4
    Scenario: nmcli - ipv4 - addresses - IP slash netmask and route
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.253/24" in editor
    * Submit "set ipv4.gateway 192.168.122.96" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "192.168.122.253/24" is visible with command "ip a s eth1"
    Then "default via 192.168.122.96 dev eth1  proto static  metric" is visible with command "ip route"
    Then "192.168.122.0/24 dev eth1  proto kernel  scope link  src 192.168.122.253" is visible with command "ip route"
    Then "default via 10." is visible with command "ip route"


    @testcase_303654
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - addresses - several IPs slash netmask and route
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.22.253/24, 192.168.122.253/16" in editor
    * Submit "set ipv4.addresses 192.168.222.253/8" in editor
    * Submit "set ipv4.gateway 192.168.22.96" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "192.168.22.253/24" is visible with command "ip a s eth1"
    Then "192.168.122.253/16" is visible with command "ip a s eth1"
    Then "192.168.222.253/8" is visible with command "ip a s eth1"
    Then "default via 192.168.22.96 dev eth1  proto static  metric" is visible with command "ip route"
    Then "default via 10." is not visible with command "ip route"


    @testcase_303655
    @ipv4
    Scenario: nmcli - ipv4 - addresses - delete IP and set method back to auto
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.22.253/24, 192.168.122.253/16" in editor
    * Submit "set ipv4.gateway 192.168.22.96" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Open editor for connection "ethie"
    * Submit "set ipv4.addresses" in editor
    * Enter in editor
    * Submit "set ipv4.gateway" in editor
    * Enter in editor
    * Submit "set ipv4.method auto" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "192.168.22.253/24" is not visible with command "ip a s eth1"
    Then "192.168.22.96" is not visible with command "ip route"
    Then "192.168.122.253/24" is not visible with command "ip a s eth1"
    Then "192.168.122.95" is not visible with command "ip route"


    @testcase_303656
    @ipv4_2
    @eth0
    Scenario: nmcli - ipv4 - routes - set basic route
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.3.10/24" in editor
    * Submit "set ipv4.gateway 192.168.4.1" in editor
    * Submit "set ipv4.routes 192.168.5.0/24 192.168.3.11 1" in editor
    * Submit "set ipv4.route-metric 21" in editor
    * Save in editor
    * Quit editor
    * Add connection type "ethernet" named "ethie2" for device "eth2"
    * Open editor for connection "ethie2"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.1.10/24" in editor
    * Submit "set ipv4.gateway 192.168.4.1" in editor
    * Submit "set ipv4.routes 192.168.2.0/24 192.168.1.11 2" in editor
    * Submit "set ipv4.route-metric 22" in editor
    * Save in editor
    * Quit editor
    #* Bring "down" connection "eth0"
    * Bring "up" connection "ethie"
    * Bring "up" connection "ethie2"
    Then "192.168.1.0/24 dev eth2  proto kernel  scope link  src 192.168.1.10" is visible with command "ip route"
    Then "192.168.2.0/24 via 192.168.1.11 dev eth2  proto static  metric" is visible with command "ip route"
    Then "192.168.3.0/24 dev eth1  proto kernel  scope link  src 192.168.3.10" is visible with command "ip route"
    Then "192.168.4.1 dev eth1  proto static  scope link  metric 21" is visible with command "ip route"
    Then "192.168.4.1 dev eth2  proto static  scope link  metric 22" is visible with command "ip route"
    Then "192.168.5.0/24 via 192.168.3.11 dev eth1  proto static  metric" is visible with command "ip route"
    #* Bring "up" connection "eth0"


    @testcase_303657
    @ipv4_2
    @eth0
    Scenario: nmcli - ipv4 - routes - remove basic route
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.3.10/24" in editor
    * Submit "set ipv4.gateway 192.168.4.1" in editor
    * Submit "set ipv4.routes 192.168.5.0/24 192.168.3.11 1" in editor
    * Submit "set ipv4.route-metric 21" in editor
    * Save in editor
    * Quit editor
    * Add connection type "ethernet" named "ethie2" for device "eth2"
    * Open editor for connection "ethie2"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.1.10/24" in editor
    * Submit "set ipv4.gateway 192.168.4.1" in editor
    * Submit "set ipv4.routes 192.168.2.0/24 192.168.1.11 2" in editor
    * Submit "set ipv4.route-metric 22" in editor
    * Save in editor
    * Quit editor
    * Open editor for connection "ethie"
    * Submit "set ipv4.routes" in editor
    * Enter in editor
    * Save in editor
    * Quit editor
    * Open editor for connection "ethie2"
    * Submit "set ipv4.routes" in editor
    * Enter in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Bring "up" connection "ethie2"
    Then "192.168.1.0/24 dev eth2  proto kernel  scope link  src 192.168.1.10" is visible with command "ip route"
    Then "192.168.2.0/24 via 192.168.1.11 dev eth2  proto static  metric 1" is not visible with command "ip route"
    Then "192.168.3.0/24 dev eth1  proto kernel  scope link  src 192.168.3.10" is visible with command "ip route"
    Then "192.168.4.1 dev eth1  proto static  scope link  metric 21" is visible with command "ip route"
    Then "192.168.4.1 dev eth2  proto static  scope link  metric 22" is visible with command "ip route"
    Then "192.168.5.0/24 via 192.168.3.11 dev eth1  proto static  metric 1" is not visible with command "ip route"


    @testcase_303658
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - routes - set device route
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.2/24" in editor
    * Submit "set ipv4.gateway 192.168.122.1" in editor
    * Submit "set ipv4.routes 192.168.1.0/24 0.0.0.0, 192.168.2.0/24 192.168.122.5" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "default via 192.168.122.1 dev eth10  proto static  metric" is visible with command "ip route"
    Then "192.168.1.0/24 dev eth10  proto static  scope link  metric" is visible with command "ip route"
    Then "192.168.2.0/24 via 192.168.122.5 dev eth10  proto static  metric" is visible with command "ip route"
    Then "192.168.122.0/24 dev eth10  proto kernel  scope link  src 192.168.122.2" is visible with command "ip route"


    @testcase_303659
    @ipv4
    Scenario: nmcli - ipv4 - routes - set invalid route - non IP
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.2/24" in editor
    * Submit "set ipv4.routes 255.255.255.256" in editor
    Then Error type "failed to set 'routes' property:" while saving in editor


    @testcase_303660
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - routes - set invalid route - missing gw
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.2/24" in editor
    * Submit "set ipv4.gateway 192.168.122.1" in editor
    * Submit "set ipv4.routes 192.168.1.0/24" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "default via 192.168.122.1 dev eth1  proto static  metric" is visible with command "ip route"
    Then "192.168.1.0/24 dev eth1  proto static  scope link  metric" is visible with command "ip route"
    Then "192.168.122.0/24 dev eth1  proto kernel  scope link  src 192.168.122.2" is visible with command "ip route"


    @ipv4_routes_not_reachable
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - routes - set unreachable route
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.2/24" in editor
    * Submit "set ipv4.gateway 192.168.122.1" in editor
    * Submit "set ipv4.routes 192.168.1.0/24 192.168.3.11 1" in editor
    * Save in editor
    * Quit editor
    * Bring up connection "ethie" ignoring error
    Then "\(disconnected\)" is visible with command "nmcli device show eth1"


    @testcase_303661
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - dns - method static + IP + dns
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.253/24" in editor
    * Submit "set ipv4.gateway 192.168.122.1" in editor
    * Submit "set ipv4.dns 8.8.8.8, 8.8.4.4" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "nameserver 8.8.8.8\s+nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 192.168.100.1" is not visible with command "cat /etc/resolv.conf"


    @testcase_303662
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - dns - method auto + dns
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dns 8.8.8.8, 8.8.4.4" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "nameserver 8.8.8.8" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 192.168.100.1" is visible with command "cat /etc/resolv.conf"


    @testcase_303663
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - dns - method auto + dns + ignore automaticaly obtained
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.ignore-auto-dns yes" in editor
    * Submit "set ipv4.dns 8.8.8.8, 8.8.4.4" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "nameserver 8.8.8.8" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 192.168.100.1" is not visible with command "cat /etc/resolv.conf"


    @testcase_303664
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - dns - add dns when one already set
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.253/24" in editor
    * Submit "set ipv4.gateway 192.168.122.1" in editor
    * Submit "set ipv4.dns 8.8.8.8" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dns 8.8.4.4" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "nameserver 8.8.8.8" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 192.168.100.1" is not visible with command "cat /etc/resolv.conf"


    @testcase_303665
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - dns - method auto then delete all dns
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dns 8.8.8.8, 8.8.4.4" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dns" in editor
    * Enter in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "nameserver 8.8.8.8" is not visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is not visible with command "cat /etc/resolv.conf"
    Then "nameserver 192.168.100.1" is visible with command "cat /etc/resolv.conf"


    @testcase_303666
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - dns-search - add dns-search
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dns-search redhat.com" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "redhat.com" is visible with command "cat /etc/resolv.conf"
    Then Ping "download.devel"
    Then Ping "brewweb.devel.redhat.com"


    @testcase_303667
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - dns-search - remove dns-search
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dns-search redhat.com" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dns-search" in editor
    * Enter in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then " redhat.com" is not visible with command "cat /etc/resolv.conf"
    Then Unable to ping "download.devel"
    Then Ping "download.devel.redhat.com"



    @testcase_303668
    @tshark
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-hostname - set dhcp-hostname
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Bring "up" connection "ethie"
    * Run child "sudo tshark -l -O bootp -i eth10 > /tmp/tshark.log"
    When "Proto" is visible with command "cat /tmp/tshark.log" in "30" seconds
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-hostname RHX" in editor
    #* Submit "set ipv4.send-hostname yes" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Finish "sleep 2; sudo kill -9 $(pidof tshark)"
    Then "RHX" is visible with command "cat /tmp/tshark.log"


    @testcase_303669
    @tshark
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-hostname - remove dhcp-hostname
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-hostname RHX" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Run child "sudo tshark -l -O bootp -i eth10 > /tmp/tshark.log"
    When "Proto" is visible with command "cat /tmp/tshark.log" in "30" seconds
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-hostname" in editor
    * Enter in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Finish "sleep 2;sudo kill -9 $(pidof tshark)"
   Then "RHX" is not visible with command "cat /tmp/tshark.log"


    @testcase_303670
    @tshark
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-send-hostname - don't send
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Bring "up" connection "ethie"
    * Run child "sudo tshark -l -O bootp -i eth10 > /tmp/hostname.log"
    When "Proto" is visible with command "cat /tmp/hostname.log" in "30" seconds
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-hostname RHY" in editor
    * Submit "set ipv4.dhcp-send-hostname no" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Finish "sleep 2; sudo kill -9 $(pidof tshark)"
    Then "RHY" is not visible with command "cat /tmp/hostname.log"


    @testcase_303671
    @tshark
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-send-hostname - send real hostname
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Bring "up" connection "ethie"
    * Run child "sudo tshark -l -O bootp -i eth10 > /tmp/tshark.log"
    When "Proto" is visible with command "cat /tmp/tshark.log" in "30" seconds
    * Open editor for connection "ethie"
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Finish "sleep 2; sudo kill -9 $(pidof tshark)"
    Then Hostname is visible in log "/tmp/tshark.log"


    @testcase_304232
    @tshark
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-send-hostname - ignore sending real hostname
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Bring "up" connection "ethie"
    * Run child "sudo tshark -l -O bootp -i eth10 > /tmp/real.log"
    Then "Proto" is visible with command "cat /tmp/real.log" in "30" seconds
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-send-hostname no" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Finish "sleep 2; sudo kill -9 $(pidof tshark)"
    Then Hostname is not visible in log "/tmp/real.log"


    @testcase_304233
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - dns-search - dns-search + ignore auto obtained routes
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv6.method ignore" in editor
    * Submit "set ipv6.ignore-auto-dns yes" in editor
    * Submit "set ipv4.dns-search redhat.com" in editor
    * Submit "set ipv4.ignore-auto-dns yes" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then " redhat.com" is visible with command "cat /etc/resolv.conf"
    Then "virtual" is not visible with command "cat /etc/resolv.conf"


    @testcase_304234
    @ipv4
    Scenario: nmcli - ipv4 - method - link-local
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method link-local" in editor
    * Submit "set ipv6.method ignore" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "169.254" is visible with command "ip a s eth1"


    @testcase_304235
    @tshark
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-client-id - set client id
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Bring "up" connection "ethie"
    * Run child "sudo tshark -l -O bootp -i eth10 -x > /tmp/tshark.log"
    Then "Proto" is visible with command "cat /tmp/tshark.log" in "30" seconds
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-client-id RHC" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Finish "sleep 2; sudo kill -9 $(pidof tshark)"
    Then "RHC" is visible with command "cat /tmp/tshark.log"
    #Then "walderon" is visible with command "cat /var/lib/NetworkManager/dhclient-eth10.conf"
    #VVV verify bug 999503
    Then "exceeds max \(255\) for precision" is not visible with command "grep exceeds max /var/log/messages"


    @testcase_304236
    @tshark
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-client-id - remove client id
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-client-id RHX" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-client-id" in editor
    * Enter in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Run child "sudo tshark -l -O bootp -i eth10 -x > /tmp/tshark.log"
    When "Proto" is visible with command "cat /tmp/tshark.log" in "30" seconds
    * Bring "up" connection "ethie"
    * Run child "sleep 2; sudo kill -9 $(pidof tshark)"
    Then "RHX" is not visible with command "cat /tmp/tshark.log"


    @testcase_304237
    @ipv4
    Scenario: nmcli - ipv4 - may-fail - set true
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-client-id 1" in editor
    * Submit "set ipv4.may-fail yes" in editor
    * Submit "set ipv6.method manual" in editor
    * Submit "set ipv6.addresses ::1" in editor
    * Save in editor
    * Quit editor
    Then Bring "up" connection "ethie"


    @testcase_304238
    @ipv4
    Scenario: nmcli - ipv4 - method - disabled
    * Add connection type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.method manual" in editor
    * Submit "set ipv6.addresses ::1" in editor
    * Save in editor
    * Quit editor
    Then Bring "up" connection "ethie"


    @testcase_304239
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - never-default - set
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.never-default yes " in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "default via 10." is not visible with command "ip route"


    @testcase_304240
    @ipv4
    @eth0
    Scenario: nmcli - ipv4 - never-default - remove
    * Add connection type "ethernet" named "ethie" for device "eth10"
    * Open editor for connection "ethie"
    * Submit "set ipv4.never-default yes" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Open editor for connection "ethie"
    * Submit "set ipv4.never-default" in editor
    * Enter in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "default via 10." is visible with command "ip route"


    @set_mtu_from_DHCP
    @mtu
    Scenario: NM - ipv4 - set dhcp received MTU
    * Finish "ip link add test1 type veth peer name test1p"
    * Finish "ip link add test2 type veth peer name test2p"
    * Finish "brctl addbr vethbr"
    * Finish "ip link set dev vethbr up"
    * Finish "brctl addif vethbr test1p test2p"
    * Finish "ip link set dev test1 up"
    * Finish "ip link set dev test1p up"
    * Finish "ip link set dev test2 up"
    * Finish "ip link set dev test2p up"
    * Finish "nmcli connection add type ethernet con-name tc1 ifname test1 ip4 192.168.99.1/24"
    * Finish "nmcli connection add type ethernet con-name tc2 ifname test2"
    * Bring "up" connection "tc1"
    * Execute "/usr/sbin/dnsmasq --conf-file --no-hosts --keep-in-foreground --bind-interfaces --except-interface=lo --clear-on-reload --strict-order --listen-address=192.168.99.1 --dhcp-range=192.168.99.10,192.168.99.254,60m --dhcp-option=option:router,192.168.99.1 --dhcp-lease-max=50 --dhcp-option-force=26,1800 &"
    * Bring "up" connection "tc2"
    Then "mtu 1800" is visible with command "ip a s test2"


    @renewal_gw_after_dhcp_outage
    @two_bridged_veths
    @dhcpd
    Scenario: NM - ipv4 - renewal gw after DHCP outage
    * Prepare veth pairs "test1,test2" bridged over "vethbr"
    * Add a new connection of type "ethernet" and options "con-name tc1 ifname test1 ip4 192.168.10.1/24"
    * Add a new connection of type "ethernet" and options "con-name tc2 ifname test2"
    * Execute "nmcli connection modify tc2 ipv4.may-fail no"
    * Execute "nmcli connection modify tc1 ipv4.never-default yes"
    * Bring "up" connection "tc1"
    * Configure dhcp server for subnet "192.168.10" with lease time "20"
    * Execute "service dhcpd restart"
    * Bring "up" connection "tc2"
    When "default" is visible with command "ip r"
    * Execute "service dhcpd stop"
    When "default" is not visible with command "ip r |grep test2" in "50" seconds
    When "tc2" is not visible with command "nmcli connection s -a" in "200" seconds
    * Execute "service dhcpd restart"
    Then "routers = 192.168.10.1" is visible with command "nmcli con show tc2" in "400" seconds


    @testcase_304241
    @ipv4
    Scenario: nmcli - ipv4 - describe
    * Open editor for a type "ethernet"
    When Check "\[method\]|\[dns\]|\[dns-search\]|\[addresses\]|\[gateway\]|\[routes\]|\[ignore-auto-routes\]|\[ignore-auto-dns\]|\[dhcp-hostname\]|\[never-default\]|\[may-fail\]" are present in describe output for object "ipv4"
    * Submit "goto ipv4" in editor

    Then Check "=== \[method\] ===\s+\[NM property description\]\s+IP configuration method. NMSettingIP4Config and NMSettingIP6Config both support \"auto\", \"manual\", and \"link-local\". See the subclass-specific documentation for other values. In general, for the \"auto\" method, properties such as \"dns\" and \"routes\" specify information that is added on to the information returned from automatic configuration.  The \"ignore-auto-routes\" and \"ignore-auto-dns\" properties modify this behavior. For methods that imply no upstream network, such as \"shared\" or \"link-local\", these properties must be empty." are present in describe output for object "method"

    Then Check "=== \[dns\] ===\s+\[NM property description\]\s+Array of IP addresses of DNS servers.\s+\[nmcli specific description\]\s+Enter a list of IPv4 addresses of DNS servers.\s+Example: 8.8.8.8, 8.8.4.4" are present in describe output for object "dns"

    Then Check "=== \[dns-search\] ===\s+\[NM property description\]\s+Array of DNS search domains." are present in describe output for object "dns-search"

    Then Check "ip\[/prefix\], ip\[/prefix\],\.\.\." are present in describe output for object "addresses"

    Then Check "gateway" are present in describe output for object "gateway"

    Then Check "=== \[routes\] ===\s+\[NM property description\]\s+Array of IP routes.\s+\[nmcli specific description\]\s+Enter a list of IPv4 routes formatted as:\s+ip\[/prefix\] \[next-hop\] \[metric\],...\s+Missing prefix is regarded as a prefix of 32.\s+Missing next-hop is regarded as 0.0.0.0.\s+Missing metric means default \(NM/kernel will set a default value\).\s+Examples: 192.168.2.0/24 192.168.2.1 3, 10.1.0.0/16 10.0.0.254\s+10.1.2.0/24" are present in describe output for object "routes"

    Then Check "=== \[ignore-auto-routes\] ===\s+\[NM property description\]\s+When \"method\" is set to \"auto\" and this property to TRUE, automatically configured routes are ignored and only routes specified in the \"routes\" property, if any, are used." are present in describe output for object "ignore-auto-routes"

    Then Check "=== \[ignore-auto-dns\] ===\s+\[NM property description\]\s+When \"method\" is set to \"auto\" and this property to TRUE, automatically configured nameservers and search domains are ignored and only nameservers and search domains specified in the \"dns\" and \"dns-search\" properties, if any, are used." are present in describe output for object "ignore-auto-dns"

    Then Check "=== \[dhcp-client-id\] ===\s+\[NM property description\]\s+A string sent to the DHCP server to identify the local machine which the DHCP server may use to customize the DHCP lease and options." are present in describe output for object "dhcp-client-id"

    Then Check "=== \[dhcp-send-hostname\] ===\s+\[NM property description\]\s+If TRUE, a hostname is sent to the DHCP server when acquiring a lease. Some DHCP servers use this hostname to update DNS databases, essentially providing a static hostname for the computer.  If the \"dhcp-hostname\" property is NULL and this property is TRUE, the current persistent hostname of the computer is sent." are present in describe output for object "dhcp-send-hostname"

    Then Check "=== \[dhcp-hostname\] ===\s+\[NM property description\]\s+If the \"dhcp-send-hostname\" property is TRUE, then the specified name will be sent to the DHCP server when acquiring a lease." are present in describe output for object "dhcp-hostname"

    Then Check "=== \[never-default\] ===\s+\[NM property description\]\s+If TRUE, this connection will never be the default connection for this IP type, meaning it will never be assigned the default route by NetworkManager." are present in describe output for object "never-default"

    Then Check "=== \[may-fail\] ===\s+\[NM property description\]\s+If TRUE, allow overall network configuration to proceed even if the configuration specified by this property times out.  Note that at least one IP configuration must succeed or overall network configuration will still fail.  For example, in IPv6-only networks, setting this property to TRUE on the NMSettingIP4Config allows the overall network configuration to succeed if IPv4 configuration fails but IPv6 configuration completes successfully." are present in describe output for object "may-fail"

