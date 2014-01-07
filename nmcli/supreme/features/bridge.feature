@testplan
Feature: nmcli - bridge

 # Background:
 #   * Close Evolution and cleanup data

	@cleanbridge
    Scenario: Clean bridge
    * "eth0" is visible with command "ifconfig"


    @bridge
    @testcase_285528
    Scenario: nmcli - bridge - add default bridge
    * Add a new connection of type "bridge" and options " "
    * Open editor for connection "bridge"
    * "nm-bridge:" is visible with command "ifconfig"
    * Note the "connection.id" property from editor print output
    * Quit editor
    Then Check ifcfg-name file created with noted connection name


	@bridge
    @testcase_285529
    Scenario: nmcli - bridge - add custom bridge
    * Add a new connection of type "bridge" and options "con-name br88 autoconnect no ifname br88 priority 5 forward-delay 3 hello-time 3 max-age 15 ageing-time 500000"
    * Bring up connection "br88" ignoring error
    * "br88:" is visible with command "ifconfig"
    Then "br88" is visible with command "brctl show"
    Then "DELAY=3.*BRIDGING_OPTS=\"priority=5 hello_time=3 max_age=15 ageing_time=500000\".*NAME=br88.*ONBOOT=no" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-br88"


	@bridge
    @testcase_285530
    Scenario: nmcli - bridge - up
    * Add a new connection of type "bridge" and options "con-name br11 ifname br11 autoconnect no"
    * Check ifcfg-name file created for connection "br11"
    * "br11" is not visible with command "brctl show"
    * Bring up connection "br11" ignoring error
    Then "br11" is visible with command "brctl show"


	@bridge
    @testcase_285531
    Scenario: nmcli - bridge - down
    * Add a new connection of type "bridge" and options "con-name br11 ifname br11 autoconnect no"
    * Check ifcfg-name file created for connection "br11"
    * Open editor for connection "br11"
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.15/24" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "br11" ignoring error
    * "br11" is visible with command "brctl show"
    * "inet 192.168.1.15" is visible with command "ifconfig"
    * Bring down connection "br11"
    * "inet 192.168.1.15" is not visible with command "ifconfig"


	@bridge
    @testcase_285532
    Scenario: nmcli - bridge - disconnect device
    * Add a new connection of type "bridge" and options "con-name br11 ifname br11 autoconnect no"
    * Check ifcfg-name file created for connection "br11"
    * Open editor for connection "br11"
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.10/24" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "br11" ignoring error
    * "br11" is visible with command "brctl show"
    * "inet 192.168.1.10" is visible with command "ifconfig"
    * Disconnect device "br11"
    * "inet 192.168.1.10" is not visible with command "ifconfig"


    @bridge
    @testcase_285533
    Scenario: nmcli - bridge - describe all
    * Open editor for a type "bridge"
    Then Check "interface-name|stp|priority|forward-delay|hello-time|max-age|ageing-time" are present in describe output for object "bridge"


    @bridge
    @testcase_285534
    Scenario: nmcli - bridge - describe separately
    * Open editor for a type "bridge"
    Then Check "\[interface-name\]" are present in describe output for object "bridge.interface-name"
    Then Check "\[stp\]" are present in describe output for object "bridge.stp"
    Then Check "\[priority\]" are present in describe output for object "bridge.priority"
    Then Check "\[forward-delay\]" are present in describe output for object "bridge.forward-delay"
    Then Check "\[hello-time\]" are present in describe output for object "bridge.hello-time"
    Then Check "\[max-age\]" are present in describe output for object "bridge.max-age"
    Then Check "\[ageing-time\]" are present in describe output for object "bridge.ageing-time"


	@bridge
    @testcase_285535
    Scenario: nmcli - bridge - delete connection
    * Add a new connection of type "bridge" and options "con-name br11 ifname br11"
    * Check ifcfg-name file created for connection "br11"
    * Bring up connection "br11" ignoring error
    * Delete connection "br11"
    Then ifcfg-"br11" file does not exist


	@bridge
    @testcase_285536
    Scenario: nmcli - bridge - delete connection while up
    * Add a new connection of type "bridge" and options "con-name br12 ifname br12 autoconnect no"
    * Check ifcfg-name file created for connection "br12"
    * Open editor for connection "br12"
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.19/24" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "br12" ignoring error
    * "inet 192.168.1.19" is visible with command "ifconfig"
    * Delete connection "br12"
    Then "inet 192.168.1.19" is not visible with command "ifconfig"
    Then ifcfg-"br12" file does not exist


	@bridge
    @testcase_285537
    Scenario: nmcli - bridge - add slave
    * Add a new connection of type "bridge" and options "con-name br15 ifname br15 autoconnect no"
    * Check ifcfg-name file created for connection "br15"
    * Add a new connection of type "vlan" and options "con-name eth1.80 dev eth1 id 80"
    * Check ifcfg-name file created for connection "eth1.80"
    * Add a new connection of type "bridge-slave" and options "autoconnect no ifname eth1.80 master br15"
    Then "BRIDGE=br15" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-bridge-slave-eth1.80"

	@bridge
    @testcase_285538
    Scenario: nmcli - bridge - remove slave
    * Add a new connection of type "bridge" and options "con-name br15 ifname br15 autoconnect no"
    * Check ifcfg-name file created for connection "br15"
    * Add a new connection of type "vlan" and options "con-name eth1.80 dev eth1 id 80"
    * Check ifcfg-name file created for connection "eth1.80"
    * Add a new connection of type "bridge-slave" and options "con-name br15-slave autoconnect no ifname eth1.80 master br15"
    * Check ifcfg-name file created for connection "br15-slave"
    * Delete connection "br15-slave"
    Then ifcfg-"br15-slave" file does not exist


	@bridge
    @testcase_285539
    Scenario: nmcli - bridge - up with slaves
    * Add a new connection of type "bridge" and options "con-name br15 ifname br15"
    * Check ifcfg-name file created for connection "br15"
    * Open editor for connection "br15"
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.19/24" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Add a new connection of type "vlan" and options "con-name eth1.80 dev eth1 id 80"
    * Check ifcfg-name file created for connection "eth1.80"
    * Add a new connection of type "vlan" and options "con-name eth1.90 dev eth1 id 90"
    * Check ifcfg-name file created for connection "eth1.90"
    * Add a new connection of type "bridge-slave" and options "con-name br15-slave1 ifname eth1.80 master br15"
    * Check ifcfg-name file created for connection "br15-slave1"
    * Add a new connection of type "bridge-slave" and options "con-name br15-slave2 ifname eth1.90 master br15"
    * Check ifcfg-name file created for connection "br15-slave2"
    * Bring up connection "br15"
    Then  "br15" is visible with command "brctl show"


	@bridge
    @testcase_285540
    Scenario: nmcli - bridge - up slave
    * Add a new connection of type "bridge" and options "con-name br10 ifname br10"
    * Check ifcfg-name file created for connection "br10"
    * Open editor for connection "br10"
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.19/24" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "br10"
    * Add a new connection of type "bridge-slave" and options "con-name br10-slave autoconnect no ifname eth1 master br10"
    * Check ifcfg-name file created for connection "br10-slave"
    * Bring up connection "br10-slave"
    Then  "br10.*eth1" is visible with command "brctl show"
    Then Disconnect device "br10"
