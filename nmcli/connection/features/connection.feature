Feature: nmcli: connection


    @connection_help
    Scenario: nmcli - connection - help and autocompletion
    Then "COMMAND :=  { show | up | down | add | modify | edit | delete | reload | load }\s+show\s+up\s+down\s+add\s+modify\s+edit\s+edit\s+delete\s+reload\s+load" is visible with command "nmcli connection help"
    Then "--active" is visible with tab after "nmcli connection show "
    Then "autoconnect\s+con\-name\s+help\s+ifname\s+type" is visible with tab after "nmcli connection add "
    Then "add|delete|down|edit|help|load|modify|reload|show|up" is visible with tab after "nmcli connection "
    Then "Usage: nmcli connection add { OPTIONS | help }\s+OPTIONS \:= COMMON_OPTIONS TYPE_SPECIFIC_OPTIONS IP_OPTIONS\s+COMMON_OPTIONS:\s+type <type>\s+ifname <interface name> |\s+ethernet\:\s+wifi:\s+ssid <SSID>\s+gsm:\s+apn <APN>\s+cdma:\s+infiniband:\s+bluetooth:\s+vlan:\s+dev <parent device \(connection  UUID, ifname, or MAC\)>\s+bond:\s+bond-slave:\s+master <master \(ifname or connection UUID\)>\s+team:\s+team-slave:\s+master <master \(ifname or connection UUID\)>\s+bridge:\s+bridge-slave:\s+master <master \(ifname or connection UUID\)>\svpn:\s+vpn-type vpnc|openvpn|pptp|openconnect|openswan\s+olpc-mesh:\s+ssid" is visible with command "nmcli connection add help"


    @connection_names_autocompletion
    @con
    Scenario: nmcli - connection - names autocompletion
    Then "eth0" is visible with tab after "nmcli connection edit id "
    Then "eth6" is visible with tab after "nmcli connection edit id "
    Then "connie" is not visible with tab after "nmcli connection edit id "
    * Add connection for a type "ethernet" named "connie" for device "eth1"
    Then "connie" is visible with tab after "nmcli connection edit "
    Then "connie" is visible with tab after "nmcli connection edit id "


    @connection_no_error
    #VV reproducer for 842975
    Scenario: nmcli - connection - no error shown
    Then "error" is not visible with command "nmcli -f DEVICE connection"
    Then "error" is not visible with command "nmcli -f DEVICE dev"
    Then "error" is not visible with command "nmcli -f DEVICE nm"


    @connection_delete_while_editing
    @con
    Scenario: nmcli - connection - delete opened connection
     * Add connection for a type "ethernet" named "connie" for device "eth1"
     * Open editor for "connie" with timeout
     * Delete connection "connie" and hit Enter
     #* Submit "save" in editor


    @connection_restricted_to_single_device
    @con
    # verification for https://bugzilla.redhat.com/show_bug.cgi?id=997998
    Scenario: nmcli - connection - restriction to single device
     * Add connection for a type "ethernet" named "connie" for device "*"
     * Bring up connection "connie" for "eth1"
    Then Fail up connection "connie" for "eth2"


    @connection_removal_of_disapperared_device
    @BBB
    Scenario: nmcli - connection - remove connection of nonexisting device
     * Finish "sudo ip link add name BBB type bridge"
     * Finish "sudo ip link del BBB"
     When "BBB" is visible with command "nmcli -f NAME show connection --active"
     * Delete connection "BBB"
     * Bring "down" connection "BBB"
    Then "Active: active" is visible with command "sudo service NetworkManager status"


    @connection_down
    @con
    @eth
    Scenario: nmcli - connection - down
     * Add connection for a type "ethernet" named "connie" for device "eth1"
     * Add connection for a type "ethernet" named "ethie" for device "eth1"
     * Bring "up" connection "connie"
     * Bring "up" connection "ethie"
     * Bring "down" connection "ethie"
     Then Check if "connie" is active connection


    @testcase_282124
    @con
    Scenario: nmcli - connection - set id
     * Add connection for a type "ethernet" named "connie" for device "blah"
     * Open editor for connection "connie"
     * Submit "set connection.id after_rename" in editor
     * Save in editor
     * Quit editor
     * Prompt is not running
     Then Open editor for connection "after_rename"
     * Quit editor
     * Delete connection "after_rename"


    @testcase_282128
    @con
    Scenario: nmcli - connection - set uuid
     * Add connection for a type "ethernet" named "connie" for device "blah"
     * Open editor for connection "connie"
     * Submit "set connection.uuid 00000000-0000-0000-0000-000000000000" in editor
     Then Error type "uuid" shown in editor


    @testcase_282130
    @con
    Scenario: nmcli - connection - set interface-name
     * Add connection for a type "ethernet" named "connie" for device "blah"
     * Open editor for connection "connie"
     * Submit "set connection.interface-name eth2" in editor
     * Save in editor
     * Quit editor
     When Prompt is not running
     * Bring "up" connection "connie"
     Then Check if "connie" is active connection


#    @testcase_285242
#    @eth
#    @connection
#    Scenario: nmcli - connection - set invalid uuid
#     * Add connection for a type "ethernet" named "connie" for device "blah"
#     * Open editor for connection "connie"
#     * Submit "set connection.uuid 00" in editor
#     Then Error type "uuid" shown in editor
#     * Quit editor


    @testcase_300559
    @con
    Scenario: nmcli - connection - set autoconnect on
     * Add connection for a type "ethernet" named "connie" for device "eth2"
     * Open editor for connection "connie"
     * Submit "set connection.autoconnect yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "connie"
     * Bring "down" connection "connie"
     * Reboot
     Then Check if "connie" is active connection


    @connection_autoconnect_warning
    @con
    Scenario: nmcli - connection - autoconnect warning while saving new
     * Open editor for new connection "connie" type "ethernet"
     * Save in editor
     Then autoconnect warning is shown
     * Enter in editor
     * Quit editor


    @testcase_300560
    @con
    Scenario: nmcli - connection - set autoconnect off
     * Add connection for a type "ethernet" named "connie" for device "eth2"
     * Open editor for connection "connie"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "connie"
     * Reboot
     Then Check if "connie" is not active connection


    @testcase_300561
    @time
    Scenario: nmcli - connection - timestamp
     * Add connection for a type "ethernet" named "time" for device "blah"
     * Open editor for connection "time"
     * Submit "set connection.autoconnect no" in editor
     * Submit "set connection.interface-name eth2" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "time"
     When Check if object item "connection.timestamp:" has value "0" via print
     * Quit editor
     * Bring "up" connection "time"
     * Open editor for connection "time"
     Then Check if object item "connection.timestamp:" has value "current_time" via print
     * Quit editor
     * Delete connection "time"


    @testcase_300562
    @con
    Scenario: nmcli - connection - readonly timestamp
     * Add connection for a type "ethernet" named "connie" for device "eth2"
     * Open editor for connection "connie"
     * Submit "set connection.timestamp 1372338021" in editor
     Then Error type "timestamp" shown in editor
     When Quit editor


    @testcase_300563
    @con
    Scenario: nmcli - connection - readonly read-only
     * Add connection for a type "ethernet" named "connie" for device "eth2"
     * Open editor for connection "connie"
     * Submit "set connection.read-only yes" in editor
     Then Error type "read-only" shown in editor


    @testcase_300564
    @con
    Scenario: nmcli - connection - readonly type
     * Add connection for a type "ethernet" named "connie" for device "eth2"
     * Open editor for connection "connie"
     * Submit "set connection.type 802-3-ethernet" in editor
     Then Error type "type" shown in editor


    @testcase_300565
    @con
    Scenario: nmcli - connection - permissions to user
     * Add connection for a type "ethernet" named "connie" for device "eth2"
     * Open editor for connection "connie"
     * Submit "set connection.permissions test" in editor
     * Save in editor
     * Check if object item "connection.permissions:" has value "user:test" via print
     * Quit editor
     * Prompt is not running
     * Bring "up" connection "connie"
     * Open editor for connection "connie"
    Then Check if object item "connection.permissions:" has value "user:test" via print
     * Quit editor
    Then "test" is visible with command "grep test /etc/sysconfig/network-scripts/ifcfg-connie"


    # @testcase_300566
    # @eth
    # @connection
    # Scenario: nmcli - connection - permissions to other non root user (under non root user)
    #  * Add connection for a type "ethernet" named "connie" for device "eth2"
    #  * Open editor for connection "connie"
    #  * Submit "set connection.permissions karel" in editor
    #  * Save in editor
    #  Then Error type "connie" while saving in editor


    @testcase_300567
    #@eth0
    @con
    @firewall
    Scenario: nmcli - connection - zone to drop and public
     * Add connection for a type "ethernet" named "connie" for device "eth6"
     * Open editor for connection "connie"
     * Submit "set connection.zone drop" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "connie"
     When "eth6" is visible with command "firewall-cmd --zone=drop --list-all"
     * Open editor for connection "connie"
     * Submit "set connection.zone" in editor
     * Enter in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "connie"
     Then "eth6" is visible with command "firewall-cmd --zone=public --list-all"


    @testcase_300568
    @con
    Scenario: nmcli - connection - describe
     * Add connection for a type "ethernet" named "connie" for device "eth2"
     * Open editor for connection "connie"
     Then Check "\[id\]|\[uuid\]|\[interface-name\]|\[type\]|\[permissions\]|\[autoconnect\]|\[timestamp\]|\[read-only\]|\[zone\]|\[master\]|\[slave-type\]|\[secondaries\]|\[gateway-ping-timeout\]" are present in describe output for object "connection"
     * Submit "goto connection" in editor

     Then Check "=== \[id\] ===\s+\[NM property description\]\s+User-readable connection identifier/name.  Must be one or more characters and may change over the lifetime of the connection if the user decides to rename it." are present in describe output for object "id"

     Then Check "=== \[uuid\] ===\s+\[NM property description\]\s+Universally unique connection identifier.  Must be in the format '2815492f\-7e56\-435e\-b2e9\-246bd7cdc664' \(ie, contains only hexadecimal characters and '\-'\). The UUID should be assigned when the connection is created and never changed as long as the connection still applies to the same network.  For example, it should not be changed when the user changes the connection's 'id', but should be recreated when the WiFi SSID, mobile broadband network provider, or the connection type changes." are present in describe output for object "uuid"

     Then Check "=== \[interface-name\] ===\s+\[NM property description\]\s+Interface name this connection is bound to. If not set, then the connection can be attached to any interface of the appropriate type \(subject to restrictions imposed by other settings\). For connection types where interface names cannot easily be made persistent \(e.g. mobile broadband or USB ethernet\), this property should not be used. Setting this property restricts the interfaces a connection can be used with, and if interface names change or are reordered the connection may be applied to the wrong interface." are present in describe output for object "interface-name"

     Then Check "=== \[type\] ===\s+\[NM property description\]\s+Base type of the connection.  For hardware-dependent connections, should contain the setting name of the hardware\-type specific setting \(ie, '802\-3\-ethernet' or '802\-11\-wireless' or 'bluetooth', etc\), and for non-hardware dependent connections like VPN or otherwise, should contain the setting name of that setting type \(ie, 'vpn' or 'bridge', etc\)." are present in describe output for object "type"

     Then Check "=== \[autoconnect\] ===\s+\[NM property description\]\s+If TRUE, NetworkManager will activate this connection when its network resources are available.  If FALSE, the connection must be manually activated by the user or some other mechanism." are present in describe output for object "autoconnect"

     Then Check "=== \[timestamp\] ===\s+\[NM property description\]\s+Timestamp \(in seconds since the Unix Epoch\) that the connection was last successfully activated.  NetworkManager updates the connection timestamp periodically when the connection is active to ensure that an active connection has the latest timestamp. The property is only meant for reading \(changes to this property will not be preserved\)." are present in describe output for object "timestamp"

     Then Check "=== \[read-only\] ===\s+\[NM property description\]\s+If TRUE, the connection is read-only and cannot be changed by the user or any other mechanism.  This is normally set for system connections whose plugin cannot yet write updated connections back out." are present in describe output for object "read-only"

     Then Check "=== \[zone\] ===\s+\[NM property description\]\s+The trust level of a the connection.Free form case-insensitive string \(for example \"Home\", \"Work\", \"Public\"\).  NULL or unspecified zone means the connection will be placed in the default zone as defined by the firewall." are present in describe output for object "zone"

     Then Check "=== \[master\] ===\s+\[NM property description\]\s+Interface name of the master device or UUID of the master connection" are present in describe output for object "master"

     Then Check "=== \[slave-type\] ===\s+\[NM property description\]\s+Setting name describing the type of slave this connection is \(ie, 'bond'\) or NULL if this connection is not a slave." are present in describe output for object "slave-type"

     Then Check "=== \[secondaries\] ===\s+\[NM property description\]\s+List of connection UUIDs that should be activated when the base connection itself is activated." are present in describe output for object "secondaries"

     Then Check "=== \[gateway-ping-timeout\] ===\s+\[NM property description]\s+If greater than zero, delay success of IP addressing until either the timeout is reached, or an IP gateway replies to a ping." are present in describe output for object "gateway-ping-timeout"

