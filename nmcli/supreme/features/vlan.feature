@testplan
Feature: nmcli - vlan

 # Background:
 #   * Close Evolution and cleanup data

    @cleanvlan
    Scenario: Clean vlan
    * "eth0" is visible with command "ifconfig"

    @vlan
    @testcase_281205
    Scenario: nmcli - vlan - add default device
     * Add a new connection of type "vlan" and options "con-name eth0.99 dev eth0 id 99"
     Then "eth0.99:" is visible with command "ifconfig"
     Then Check ifcfg-name file created for connection "eth0.99"


    @vlan
    @testcase_281263
    Scenario: nmcli - vlan - remove connection
    Given "inet 10.42." is not visible with command "ifconfig"
    * Add a new connection of type "vlan" and options "con-name eth0.299 dev eth0 id 299"
    * Open editor for connection "eth0.299"
    * Set a property named "ipv4.method" to "shared" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "eth0.299"
    * "inet 10.42." is visible with command "ifconfig"
    * Delete connection "eth0.299"
    * Wait for at least "5" seconds
    Then "inet 10.42." is not visible with command "ifconfig"
    Then ifcfg-"eth0.299" file does not exist


    @vlan
    @testcase_281326
    Scenario: nmcli - vlan - connection up
    * Add a new connection of type "vlan" and options "con-name eth0.99 autoconnect no dev eth0 id 99"
    * Open editor for connection "eth0.99"
    * Set a property named "ipv4.method" to "shared" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * "eth0.99" is not visible with command "ifconfig"
    * Bring up connection "eth0.99"
    Then "eth0.99" is visible with command "ifconfig"


    @vlan
    @testcase_284356
    Scenario: nmcli - vlan - connection up while up
    * Add a new connection of type "vlan" and options "con-name eth0.99 autoconnect yes dev eth0 id 99"
    Then "eth0.99" is visible with command "ifconfig"
    * Open editor for connection "eth0.99"
    * Set a property named "ipv4.method" to "shared" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    # With no errors
    Then Bring up connection "eth0.99"


    @vlan
    @testcase_281271
    Scenario: nmcli - vlan - connection down
    * "inet 10.42." is not visible with command "ifconfig"
    * Add a new connection of type "vlan" and options "con-name eth0.399 dev eth0 id 399"
    * Open editor for connection "eth0.399"
    * Set a property named "ipv4.method" to "shared" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Set a property named "connection.autoconnect" to "no" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "eth0.399"
    * "inet 10.42." is visible with command "ifconfig"
    * Bring down connection "eth0.399"
    Then "inet 10.42." is not visible with command "ifconfig"

    @vlan
    @testcase_281264
    Scenario: nmcli - vlan - connection down (autoconnect on)
    * "inet 10.42." is not visible with command "ifconfig"
    * Add a new connection of type "vlan" and options "con-name eth0.399 dev eth0 id 399"
    * Open editor for connection "eth0.399"
    * Set a property named "ipv4.method" to "shared" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "eth0.399"
    * "inet 10.42." is visible with command "ifconfig"
    * Bring down connection "eth0.399"
    * Wait for at least "10" seconds
    Then "inet 10.42." is visible with command "ifconfig"

    @vlan
    @testcase_281332
    Scenario: nmcli - vlan - change id without interface set
    * Add a new connection of type "vlan" and options "con-name eth0.65 dev eth0 id 65"
    * Open editor for connection "eth0.65"
    * Set a property named "ipv4.method" to "shared" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Quit editor
    * Check value saved message showed in editor
    * "eth0.65:" is visible with command "ifconfig"
    * Open editor for connection "eth0.65"
    * Set a property named "vlan.id" to "55" in editor
    * Save in editor
    * Error appeared in editor

    @vlan
    @testcase_281394
    Scenario: nmcli - vlan - change id
    * Add a new connection of type "vlan" and options "con-name eth0.165 autoconnect no dev eth0 id 165"
    * Open editor for connection "eth0.165"
    * Set a property named "ipv4.method" to "shared" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * No error appeared in editor
    * Save in editor
    * Quit editor
    * Check value saved message showed in editor
    * Bring up connection "eth0.165"
    * Bring down connection "eth0.165"
    * Open editor for connection "eth0.165"
    * Set a property named "vlan.id" to "265" in editor
    * Set a property named "vlan.interface-name" to "eth0.265" in editor
    * Set a property named "connection.id" to "eth0.265" in editor
    * Set a property named "connection.interface-name" to "eth0.265" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * "eth0.265:" is not visible with command "ifconfig"
    * "inet 10.42.0.1" is not visible with command "ifconfig"
    * Bring up connection "eth0.265"
    Then "eth0.265:" is visible with command "ifconfig"
    Then "inet 10.42.0.1" is visible with command "ifconfig"

    @vlan
    @testcase_284357
    Scenario: nmcli - vlan - describe all
    * Open editor for a type "vlan"
    Then Check "interface-name|parent|id|flags|ingress-priority-map|egress-priority-map" are present in describe output for object "vlan"


    @vlan
    @testcase_281282
    Scenario: nmcli - vlan - describe separately
    * Open editor for a type "vlan"
    Then Check "\[interface-name\]" are present in describe output for object "vlan.interface-name"
    Then Check "\[parent\]" are present in describe output for object "vlan.parent"
    Then Check "\[id\]" are present in describe output for object "vlan.id"
    Then Check "\[flags\]" are present in describe output for object "vlan.flags"
    Then Check "\[ingress-priority-map\]" are present in describe output for object "vlan.ingress-priority-map"
    Then Check "\[egress-priority-map\]" are present in describe output for object "vlan.egress-priority-map"


    @vlan
    @testcase_284358
    Scenario: nmcli - vlan - disconnect device
    * "inet 10.42." is not visible with command "ifconfig"
    * Add a new connection of type "vlan" and options "con-name eth0.399 dev eth0 id 399"
    * Open editor for connection "eth0.399"
    * Set a property named "ipv4.method" to "shared" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Set a property named "connection.autoconnect" to "no" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "eth0.399"
    * "inet 10.42." is visible with command "ifconfig"
    * Disconnect device "eth0.399"
    Then "inet 10.42." is not visible with command "ifconfig"

    @vlan
    @testcase_284359
    Scenario: nmcli - vlan - disconnect device (with autoconnect)
    * "inet 10.42." is not visible with command "ifconfig"
    * Add a new connection of type "vlan" and options "con-name eth0.499 dev eth0 id 499"
    * Open editor for connection "eth0.499"
    * Set a property named "ipv4.method" to "shared" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "eth0.499"
    * "inet 10.42." is visible with command "ifconfig"
    * Disconnect device "eth0.499"
    Then "inet 10.42." is not visible with command "ifconfig"

    @vlan
    @testcase_281211
    Scenario: nmcli - vlan - device tagging
    * Execute "yum -y install wireshark"
    * Add a new connection of type "vlan" and options "con-name eth0.80 dev eth0 id 80"
    * "eth0.80:" is visible with command "ifconfig"
    * Spawn process "ping -I eth0.80 8.8.8.8"
    Then "ID: 80" is visible with command "tshark -T fields -e vlan"
    Then Terminate spawned process "ping -I eth0.80 8.8.8.8"
