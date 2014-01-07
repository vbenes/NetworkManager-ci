Feature: nmcli: ipv4


    @testcase_303647
    @ipv4
    Scenario: nmcli - ipv4 - method - static without IP
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Save in editor
    Then Error type "connection verification failed: ipv4.addresses: property is missing" while saving in editor


    @testcase_303648
    @ipv4
    Scenario: nmcli - ipv4 - method - manual + IP
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 192.168.122.253" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "192.168.122.253/32" is visible with command "ip a s eth1"


    @testcase_303649
    @ipv4
    Scenario: nmcli - ipv4 - method - static + IP
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
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
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
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
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.253/8" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "192.168.122.253/8" is visible with command "ip a s eth1"


#    @testcase_hash
#    @ipv4
#    Scenario: nmcli - ipv4 - addresses - IP slash IP netmask
#    * Add connection for a type "ethernet" named "ethie" for device "eth1"
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
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.253/192.168.122.1" in editor
    Then Error type "failed to set 'addresses' property: invalid prefix '192.168.122.1'; <1-32> allowed" while saving in editor


    @testcase_303653
    @ipv4
    Scenario: nmcli - ipv4 - addresses - IP slash netmask and route
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.253/24 192.168.122.96" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "192.168.122.253/24" is visible with command "ip a s eth1"
    Then "default via 192.168.122.96" is not visible with command "ip route"
    Then "default via 10." is visible with command "ip route"


    @testcase_303654
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - addresses - several IPs slash netmask and route
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.22.253/24 192.168.22.96, 192.168.122.253/16 192.168.122.95" in editor
    * Submit "set ipv4.addresses 192.168.222.253/8 192.168.222.94" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "192.168.22.253/24" is visible with command "ip a s eth1"
    Then "default via 192.168.22.96" is visible with command "ip route"
    Then "192.168.122.253/16" is visible with command "ip a s eth1"
    Then "192.168.122.95" is not visible with command "ip route"
    Then "192.168.222.253/8" is visible with command "ip a s eth1"
    Then "192.168.222.94" is not visible with command "ip route"


    @testcase_303655
    @ipv4
    Scenario: nmcli - ipv4 - addresses - delete IP and set method back to auto
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.22.253/24 192.168.22.96, 192.168.122.253/16 192.168.122.95" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Open editor for connection "ethie"
    * Submit "set ipv4.addresses" in editor
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
    @eth0
    @ipv4_2
    Scenario: nmcli - ipv4 - routes - set basic route
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.3.10/24 192.168.4.1" in editor
    * Submit "set ipv4.routes 192.168.5.0/24 192.168.3.11 1" in editor
    * Save in editor
    * Quit editor
    * Add connection for a type "ethernet" named "ethie2" for device "eth2"
    * Open editor for connection "ethie2"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.1.10/24 192.168.4.1" in editor
    * Submit "set ipv4.routes 192.168.2.0/24 192.168.1.11 2" in editor
    * Save in editor
    * Quit editor
    #* Bring "down" connection "eth0"
    * Bring "up" connection "ethie"
    * Bring "up" connection "ethie2"
    Then "192.168.1.0/24 dev eth2  proto kernel  scope link  src 192.168.1.10" is visible with command "ip route"
    Then "192.168.2.0/24 via 192.168.1.11 dev eth2  proto static  metric 1" is visible with command "ip route"
    Then "192.168.3.0/24 dev eth1  proto kernel  scope link  src 192.168.3.10" is visible with command "ip route"
    Then "192.168.4.1 dev eth1  proto static  scope link  metric 1024" is visible with command "ip route"
    Then "192.168.5.0/24 via 192.168.3.11 dev eth1  proto static  metric 1" is visible with command "ip route"
    #* Bring "up" connection "eth0"


    @testcase_303657
    @eth0
    @ipv4_2
    Scenario: nmcli - ipv4 - routes - remove basic route
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.3.10/24 192.168.4.1" in editor
    * Submit "set ipv4.routes 192.168.5.0/24 192.168.3.11 1" in editor
    * Save in editor
    * Quit editor
    * Add connection for a type "ethernet" named "ethie2" for device "eth2"
    * Open editor for connection "ethie2"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.1.10/24 192.168.4.1" in editor
    * Submit "set ipv4.routes 192.168.2.0/24 192.168.1.11 2" in editor
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
    Then "192.168.4.1 dev eth1  proto static  scope link  metric 1024" is visible with command "ip route"
    Then "192.168.5.0/24 via 192.168.3.11 dev eth1  proto static  metric 1" is not visible with command "ip route"


    @testcase_303658
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - routes - set device route
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.2/24 192.168.122.1" in editor
    * Submit "set ipv4.routes 192.168.1.0/24 0.0.0.0, 192.168.2.0/24 192.168.1.5 " in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "default via 192.168.122.1 dev eth1  proto static  metric 1024" is visible with command "ip route"
    Then "192.168.1.0/24 dev eth1  proto static  scope link  metric 1" is visible with command "ip route"
    Then "192.168.2.0/24 via 192.168.1.5 dev eth1  proto static  metric 1" is visible with command "ip route"
    Then "192.168.122.0/24 dev eth1  proto kernel  scope link  src 192.168.122.2" is visible with command "ip route"


    @testcase_303659
    @ipv4
    Scenario: nmcli - ipv4 - routes - set invalid route - non IP
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.2/24 192.168.122.1" in editor
    * Submit "set ipv4.routes 255.255.255.256" in editor
    Then Error type "failed to set 'routes' property: '255.255.255.256' is not valid" while saving in editor


    @testcase_303660
    @ipv4
    Scenario: nmcli - ipv4 - routes - set invalid route - missing gw
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.2/24 192.168.122.1" in editor
    * Submit "set ipv4.routes 1.1.1.0/24" in editor
    Then Error type "failed to set 'routes' property: '1.1.1.0" while saving in editor


    @ipv4_routes_not_reachable
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - routes - set unreachable route
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.2/24 192.168.122.1" in editor
    * Submit "set ipv4.routes 192.168.1.0/24 192.168.3.11 1" in editor
    * Save in editor
    * Quit editor
    * Bring up connection "ethie" ignoring error
    Then "\(disconnected\)" is visible with command "nmcli device show eth1"


    @testcase_303661
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - dns - method static + IP + dns
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.253/24 192.168.122.1" in editor
    * Submit "set ipv4.dns 8.8.8.8, 8.8.4.4" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "nameserver 8.8.8.8\s+nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 10." is not visible with command "cat /etc/resolv.conf"


    @testcase_303662
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - dns - method auto + dns
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dns 8.8.8.8, 8.8.4.4" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "nameserver 8.8.8.8" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 10." is visible with command "cat /etc/resolv.conf"


    @testcase_303663
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - dns - method auto + dns + ignore automaticaly obtained
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.ignore-auto-dns yes" in editor
    * Submit "set ipv4.dns 8.8.8.8, 8.8.4.4" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "nameserver 8.8.8.8" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 10." is not visible with command "cat /etc/resolv.conf"


    @testcase_303664
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - dns - add dns when one already set
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method static" in editor
    * Submit "set ipv4.addresses 192.168.122.253/24 192.168.122.1" in editor
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
    Then "nameserver 10." is not visible with command "cat /etc/resolv.conf"


    @testcase_303665
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - dns - method auto then delete all dns
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
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
    Then "nameserver 10." is visible with command "cat /etc/resolv.conf"


    @testcase_303666
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - dns-search - add dns-search
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dns-search redhat.com" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "redhat.com" is visible with command "cat /etc/resolv.conf"
    Then Ping "download.devel"
    Then Ping "brewweb.devel.redhat.com"


    @testcase_303667
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - dns-search - remove dns-search
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
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
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-hostname - set dhcp-hostname
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-hostname lulin" in editor
    #* Submit "set ipv4.send-hostname yes" in editor
    * Save in editor
    * Quit editor
    * Run child "sudo tshark -O bootp -i eth1 > /tmp/tshark.log"
    * Bring "up" connection "ethie"
    * Run child "sudo kill -9 $(pidof tshark)"
    Then "Host Name: lulin" is visible with command "cat /tmp/tshark.log"


    @testcase_303669
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-hostname - remove dhcp-hostname
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-hostname lulin" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-hostname" in editor
    * Enter in editor
    * Save in editor
    * Quit editor
    * Run child "sudo tshark -O bootp -i eth1 > /tmp/tshark.log"
    * Bring "up" connection "ethie"
    * Run child "sudo kill -9 $(pidof tshark)"
   Then "Host Name: lulin" is not visible with command "cat /tmp/tshark.log"


    @testcase_303670
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-send-hostname - don't send
    * Add connection for a type "ethernet" named "ethie" for device "eth2"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-hostname lulin" in editor
    * Submit "set ipv4.dhcp-send-hostname no" in editor
    * Save in editor
    * Quit editor
    * Run child "sudo tshark -O bootp -i eth2 > /tmp/hostname.log"
    * Bring "up" connection "ethie"
    * Run child "sudo kill -9 $(pidof tshark)"
    Then "lulin" is not visible with command "grep lulin /tmp/hostname.log"


    @testcase_303671
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-send-hostname - send real hostname
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Save in editor
    * Quit editor
    * Run child "sudo tshark -O bootp -i eth1 > /tmp/tshark.log"
    * Bring "up" connection "ethie"
    * Run child "sudo kill -9 $(pidof tshark)"
    Then "Host Name: qe-dell" is visible with command "cat /tmp/tshark.log"


    @testcase_304232
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-send-hostname - ignore sending real hostname
    * Add connection for a type "ethernet" named "ethie" for device "eth2"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-send-hostname no" in editor
    * Save in editor
    * Quit editor
    * Run child "sudo tshark -O bootp -i eth2 > /tmp/real.log"
    * Bring "up" connection "ethie"
    * Run child "sudo kill -9 $(pidof tshark)"
    Then "Host Name" is not visible with command "grep qe-dell-ovs5-vm /tmp/real.log"


    @testcase_304233
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - dns-search - dns-search + ignore auto obtained routes
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dns-search redhat.com" in editor
    * Submit "set ipv4.ignore-auto-dns yes" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then " redhat.com" is visible with command "cat /etc/resolv.conf"
    Then "eng.bos.redhat.com" is not visible with command "cat /etc/resolv.conf"


    @testcase_304234
    @ipv4
    Scenario: nmcli - ipv4 - method - link-local
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method link-local" in editor
    * Submit "set ipv6.method ignore" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "169.254" is visible with command "ip a s eth1"


    @testcase_304235
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-client-id - set client id
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-client-id karel" in editor
    * Save in editor
    * Quit editor
    * Run child "sudo tshark -i eth1 -f 'port 67 or 68' -V -x > /tmp/tshark.log"
    * Bring "up" connection "ethie"
    * Run child "sudo kill -9 $(pidof tshark)"
    Then "kare" is visible with command "cat /tmp/tshark.log"
    Then "Option: \(61\) Client identifier\s+Length: 5" is visible with command "cat /tmp/tshark.log"
    #VVV verify bug 999503
    Then "karel" is visible with command "cat /var/lib/NetworkManager/dhclient-eth1.conf"
    Then "exceeds max \(255\) for precision" is not visible with command "grep exceeds max /var/log/messages"


    @testcase_304236
    @ipv4
    Scenario: nmcli - ipv4 - dhcp-client-id - remove client id
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-client-id karel" in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    * Open editor for connection "ethie"
    * Submit "set ipv4.dhcp-client-id" in editor
    * Enter in editor
    * Save in editor
    * Quit editor
    * Run child "sudo tshark -i eth1 -f 'port 67 or 68' -V -x > /tmp/tshark.log"
    * Bring "up" connection "ethie"
    * Run child "sudo kill -9 $(pidof tshark)"
    Then "kare" is not visible with command "cat /tmp/tshark.log"
    Then "Option: \(61\) Client identifier\s+Length: 5" is not visible with command "cat /tmp/tshark.log"


    @testcase_304237
    @ipv4
    Scenario: nmcli - ipv4 - may-fail - set true
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
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
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.method disabled" in editor
    * Submit "set ipv6.method manual" in editor
    * Submit "set ipv6.addresses ::1" in editor
    * Save in editor
    * Quit editor
    Then Bring "up" connection "ethie"


    @testcase_304239
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - never-default - set
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    * Submit "set ipv4.never-default yes " in editor
    * Save in editor
    * Quit editor
    * Bring "up" connection "ethie"
    Then "default via 10." is not visible with command "ip route"


    @testcase_304240
    @eth0
    @ipv4
    Scenario: nmcli - ipv4 - never-default - remove
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
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


    @testcase_304241
    @ipv4
    Scenario: nmcli - ipv4 - describe
    * Add connection for a type "ethernet" named "ethie" for device "eth1"
    * Open editor for connection "ethie"
    When Check "\[method\]|\[dns\]|\[dns-search\]|\[addresses\]|\[routes\]|\[ignore-auto-routes\]|\[ignore-auto-dns\]|\[dhcp-client-id\]|\[dhcp-send-hostname\]|\[dhcp-hostname\]|\[never-default\]|\[may-fail\]" are present in describe output for object "ipv4"
    * Submit "goto ipv4" in editor
    Then Check "=== \[method\] ===\s+\[NM property description\]\s+IPv4 configuration method.  If 'auto' is specified then the appropriate automatic method \(DHCP, PPP, etc\) is used for the interface and most other properties can be left unset.  If 'link-local' is specified, then a link-local address in the 169.254\/16 range will be assigned to the interface.  If 'manual' is specified, static IP addressing is used and at least one IP address must be given in the 'addresses' property.  If 'shared' is specified \(indicating that this connection will provide network access to other computers\) then the interface is assigned an address in the 10.42.x.1\/24 range and a DHCP and forwarding DNS server are started, and the interface is NAT-ed to the current default network connection.  'disabled' means IPv4 will not be used on this connection.  This property must be set." are present in describe output for object "method"
    Then Check "=== \[dns\] ===\s+\[NM property description\]\s+List of DNS servers \(network byte order\). For the 'auto' method, these DNS servers are appended to those \(if any\) returned by automatic configuration.  DNS servers cannot be used with the 'shared', 'link-local', or 'disabled' methods as there is no upstream network.  In all other methods, these DNS servers are used as the only DNS servers for this connection.\s+\[nmcli specific description\]\s+Enter a list of IPv4 addresses of DNS servers.\s+Example: 8.8.8.8, 8.8.4.4" are present in describe output for object "dns"
    Then Check "=== \[dns-search\] ===\s+\[NM property description\]\s+List of DNS search domains.  For the 'auto' method, these search domains are appended to those returned by automatic configuration. Search domains cannot be used with the 'shared', 'link-local', or 'disabled' methods as there is no upstream network.  In all other methods, these search domains are used as the only search domains for this connection." are present in describe output for object "dns-search"
    Then Check "=== \[addresses\] ===\s+\[NM property description\]\s+Array of IPv4 address structures.  Each IPv4 address structure is composed of 3 32-bit values; the first being the IPv4 address \(network byte order\), the second the prefix \(1 - 32\), and last the IPv4 gateway \(network byte order\). The gateway may be left as 0 if no gateway exists for that subnet.  For the 'auto' method, given IP addresses are appended to those returned by automatic configuration.  Addresses cannot be used with the 'shared', 'link-local', or 'disabled' methods as addressing is either automatic or disabled with these methods.\s+\[nmcli specific description\]\s+Enter a list of IPv4 addresses formatted as:\s+ ip\[\/prefix\] \[gateway\], ip\[\/prefix\] \[gateway\],...\s+Missing prefix is regarded as prefix of 32.\s+Example: 192.168.1.5\/24 192.168.1.1, 10.0.0.11\/24" are present in describe output for object "addresses"
    Then Check "=== \[routes\] ===\s+\[NM property description\]\s+Array of IPv4 route structures.  Each IPv4 route structure is composed of 4 32-bit values; the first being the destination IPv4 network or address \(network byte order\), the second the destination network or address prefix \(1 - 32\), the third being the next-hop \(network byte order\) if any, and the fourth being the route metric. For the 'auto' method, given IP routes are appended to those returned by automatic configuration.  Routes cannot be used with the 'shared', 'link-local', or 'disabled', methods as there is no upstream network.\s+\[nmcli specific description\]\s+Enter a list of IPv4 routes formatted as:\s+ip\/\[prefix\] next-hop \[metric\],...\s+Missing prefix is regarded as a prefix of 32.\s+Missing metric is regarded as a metric of 0.\s+Example: 192.168.2.0\/24 192.168.2.1 3, 10.1.0.0\/16 10.0.0.254" are present in describe output for object "routes"
    Then Check "=== \[ignore-auto-routes\] ===\s+\[NM property description\]\s+When the method is set to 'auto' and this property to TRUE, automatically configured routes are ignored and only routes specified in the 'routes' property, if any, are used." are present in describe output for object "ignore-auto-routes"
    Then Check "=== \[ignore-auto-dns\] ===\s+\[NM property description\]\s+When the method is set to 'auto' and this property to TRUE, automatically configured nameservers and search domains are ignored and only nameservers and search domains specified in the 'dns' and 'dns-search' properties, if any, are used." are present in describe output for object "ignore-auto-dns"
    Then Check "=== \[dhcp-client-id\] ===\s+\[NM property description\]\s+A string sent to the DHCP server to identify the local machine which the DHCP server may use to customize the DHCP lease and options." are present in describe output for object "dhcp-client-id"
    Then Check "=== \[dhcp-send-hostname\] ===\s+\[NM property description\]\s+If TRUE, a hostname is sent to the DHCP server when acquiring a lease.\s+Some DHCP servers use this hostname to update DNS databases, essentially providing a static hostname for the computer.  If the 'dhcp-hostname' property is empty and this property is TRUE, the current persistent hostname of the computer is sent." are present in describe output for object "dhcp-send-hostname"
    Then Check "=== \[dhcp-hostname\] ===\s+\[NM property description\]\s+If the 'dhcp-send-hostname' property is TRUE, then the specified name will be sent to the DHCP server when acquiring a lease." are present in describe output for object "dhcp-hostname"
    Then Check "=== \[never-default\] ===\s+\[NM property description\]\s+If TRUE, this connection will never be the default IPv4 connection, meaning it will never be assigned the default route by NetworkManager." are present in describe output for object "never-default"
    Then Check "=== \[may-fail\] ===\s+\[NM property description\]\s+If TRUE, allow overall network configuration to proceed even if IPv4 configuration times out. Note that at least one IP configuration must succeed or overall network configuration will still fail.  For example, in IPv6-only networks, setting this property to TRUE allows the overall network configuration to succeed if IPv4 configuration fails but IPv6 configuration completes successfully." are present in describe output for object "may-fail"

