 Feature: nmcli: bond


    @testcase_281207
    @slaves
    @bond
    Scenario: nmcli - bond - add default bond
     * Open editor for a type "bond"
     * Save in editor
     * Enter in editor
     Then Value saved message showed in editor
     * Quit editor
     Then Prompt is not running
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Bring "up" connection "bond0.0"
     Then Check bond "nm-bond" in proc


    @nmcli_novice_mode_create_bond_with_default_options
    @slaves
    @bond
    Scenario: nmcli - bond - novice - create bond with default options
     * Open wizard for adding new connection
     * Expect "Connection type"
     * Submit "bond" in editor
     * Expect "Do you want to provide them\? \(yes\/no\) \[yes\]"
     * Submit "no" in editor
     * Expect "Do you want to add IP addresses\? \(yes\/no\) \[yes\]"
     * Submit "no" in editor
     * Finish "sleep 3"
    Then Check bond "nm-bond" state is "up"


    @nmcli_novice_mode_create_bond_with_mii_monitor_values
    @slaves
    @bond
    Scenario: nmcli - bond - novice - create bond with miimon monitor
     * Open wizard for adding new connection
     * Expect "Connection type"
     * Submit "bond" in editor
     * Expect "Do you want to provide them\? \(yes\/no\) \[yes\]"
     * Enter in editor
     * Expect "Bonding mode"
     * Submit "0" in editor
     * Expect "Bonding monitoring mode \(miimon\/arp\) \[miimon\]"
     * Enter in editor
     * Expect "Bonding miimon \[100\]"
     * Submit "100" in editor
     * Expect "Bonding downdelay \[0\]"
     * Submit "200" in editor
     * Expect "Bonding updelay \[0\]"
     * Submit "400" in editor
     * Expect "Do you want to add IP addresses\? \(yes\/no\) \[yes\]"
     * Submit "no" in editor
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Bring "up" connection "bond"
    Then Check bond "nm-bond" state is "up"
    Then "MII Polling Interval \(ms\): 100" is visible with command "cat /proc/net/bonding/nm-bond"
    Then "Up Delay \(ms\): 400" is visible with command "cat /proc/net/bonding/nm-bond"
    Then "Down Delay \(ms\): 200" is visible with command "cat /proc/net/bonding/nm-bond"


    @nmcli_novice_mode_create_bond_with_arp_monitor_values
    @slaves
    @bond
    Scenario: nmcli - bond - novice - create bond with arp monitor
     * Open wizard for adding new connection
     * Expect "Connection type"
     * Submit "bond" in editor
     * Expect "Do you want to provide them\? \(yes\/no\) \[yes\]"
     * Enter in editor
     * Expect "Bonding mode"
     * Submit "1" in editor
     * Expect "Bonding primary interface \[none\]"
     * Enter in editor
     * Expect "Bonding monitoring mode \(miimon\/arp\) \[miimon\]"
     * Submit "arp" in editor
     * Expect "Bonding arp-interval \[0\]"
     * Submit "100" in editor
     * Expect "Bonding arp-ip-target \[none\]"
     * Submit "192.168.100.1" in editor
     * Expect "Do you want to add IP addresses\? \(yes\/no\) \[yes\]"
     * Submit "no" in editor
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Bring "up" connection "bond"
     Then "Bonding Mode: fault-tolerance \(active-backup\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "MII Polling Interval \(ms\): 0" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "Up Delay \(ms\): 0" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "Down Delay \(ms\): 0" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "ARP Polling Interval \(ms\): 100" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "ARP IP target/s \(n.n.n.n form\): 192.168.100.1" is visible with command "cat /proc/net/bonding/nm-bond"


    @nmcli_novice_mode_create_bond-slave_with_default_options
    @slaves
    @bond
    Scenario: nmcli - bond - novice - create bond-slave with default options
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Open wizard for adding new connection
     * Expect "Connection type"
     * Submit "bond-slave" in editor
     * Expect "Interface name"
     * Submit "eth1" in editor
     * Expect "Bond master"
     * Submit "nm-bond" in editor
    * Bring "up" connection "bond-slave-eth1"
    Then Check bond "nm-bond" state is "up"
    Then Check slave "eth1" in bond "nm-bond" in proc


    @testcase_280563
    @slaves
    @bond
    Scenario: nmcli - bond - add slaves
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Bring "up" connection "bond0"
     Then Check slave "eth1" in bond "nm-bond" in proc
     Then Check slave "eth2" in bond "nm-bond" in proc


    @add_bond_master_via_uuid
    @slaves
    @bond
    # bug verification for 1057494
    Scenario: nmcli - bond - master via uuid
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "bond0" on device "eth1" named "bond0.0"
     * Bring "up" connection "bond0.0"
    Then Check slave "eth1" in bond "nm-bond" in proc


    @testcase_280567
    @slaves
    @bond
    Scenario: nmcli - bond - remove all slaves
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Bring "up" connection "bond0.0"
     * Delete connection "bond0.0"
     Then Check bond "nm-bond" state is "down"


    @testcase_280565
    @slaves
    @bond
    Scenario: nmcli - bond - remove slave
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Bring "up" connection "bond0"
     * Delete connection "bond0.1"
     Then Check bond "nm-bond" state is "up"
     Then Check slave "eth1" in bond "nm-bond" in proc


    @testcase_301107
    @slaves
    @bond
    Scenario: nmcli - connection - slave-type and master settings
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add connection type "ethernet" named "bond0.0" for device "eth1"
     * Open editor for connection "bond0.0"
     * Set a property named "connection.slave-type" to "bond" in editor
     * Set a property named "connection.master" to "nm-bond" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then Check bond "nm-bond" state is "up"
     Then Check slave "eth1" in bond "nm-bond" in proc



    #this VVV is all wrong as secondaries will be disabled for non vpn connections

    # @testcase_301108
    # @slaves
    # @bond
    # Scenario: nmcli - connection - secondaries
    #  * Add connection type "bond" named "bond0" for device "nm-bond"
    #  * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
    #  * Open editor for connection "bond0"
    #  * Submit "set connection.uuid 00000000-0000-0000-0000-000000000000" in editor
    #  * Save in editor
    #  * Quit editor
    #  * Open editor for connection "bond0.0"
    #  * Set a property named "connection.secondaries" to "00000000-0000-0000-0000-000000000000" in editor
    #  * Save in editor
    #  * Quit editor
    #  * Bring "up" connection "bond0.0"
    #  #* Bring "up" connection "bond0"
    #  Then Check bond "nm-bond" state is "up"
    #  Then Check slave "eth1" in bond "nm-bond" in proc



    @testcase_280562
    @slaves
    @bond
    Scenario: nmcli - bond - remove active bond profile
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Bring "up" connection "bond0.0"
     Then Check bond "nm-bond" state is "up"
     * Delete connection "bond0"
     Then Check bond "nm-bond" state is "down"



    @testcase_281210
    @slaves
    @bond
    Scenario: nmcli - bond - disconnect active bond
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Bring "up" connection "bond0.0"
     * Bring "up" connection "bond0.1"
     * Disconnect device "nm-bond"
     Then Check bond "nm-bond" state is "down"



    @testcase_281356
    @slaves
    @bond
    Scenario: nmcli - bond - start bond by hand
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Disconnect device "nm-bond"
     * Bring "down" connection "bond0.0"
     * Bring "down" connection "bond0.1"
     Then Check bond "nm-bond" state is "down"
     * Bring "up" connection "bond0.0"
     * Bring "up" connection "bond0.1"
     Then Check bond "nm-bond" state is "up"
     Then Check slave "eth1" in bond "nm-bond" in proc
     Then Check slave "eth2" in bond "nm-bond" in proc


    @bond_start_by_hand_no_slaves
    @slaves
    @bond
    Scenario: nmcli - bond - start bond by hand with no slaves
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Disconnect device "nm-bond"
     * Bring "down" connection "bond0.0"
     * Bring "down" connection "bond0.1"
     Then Check bond "nm-bond" state is "down"
     * Bring up connection "bond0" ignoring error
     Then Check bond "nm-bond" state is "up"
     Then Check slave "eth1" not in bond "nm-bond" in proc
     Then Check slave "eth2" not in bond "nm-bond" in proc


    @bond_activate
    @slaves
    @bond
    Scenario: nmcli - bond - activate
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Disconnect device "nm-bond"
     * Bring "down" connection "bond0.0"
     * Bring "down" connection "bond0.1"
     Then Check bond "nm-bond" state is "down"
     * Open editor for connection "bond0.0"
     * Submit "activate" in editor
     * Enter in editor
     * Quit editor
     Then Check bond "nm-bond" state is "up"
     Then Check slave "eth1" in bond "nm-bond" in proc
     Then Check slave "eth2" not in bond "nm-bond" in proc


    @bond_start_by_hand_with_one_auto_only
    @slaves
    @bond
    Scenario: nmcli - bond - start bond by hand with on auto only
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0.0"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "bond0.0"
     * Bring "up" connection "bond0.1"
     * Bring "up" connection "bond0"
     Then Check bond "nm-bond" state is "up"
     Then Check slave "eth1" not in bond "nm-bond" in proc
     Then Check slave "eth2" in bond "nm-bond" in proc


    @testcase_281361
    @slaves
    @bond
    Scenario: nmcli - bond - start bond on boot
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0.0"
     * Submit "set connection.autoconnect yes" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "bond0.1"
     * Submit "set connection.autoconnect yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "bond0"
     * Reboot
     Then Check bond "nm-bond" state is "up"
     Then Check slave "eth1" in bond "nm-bond" in proc
     Then Check slave "eth2" in bond "nm-bond" in proc



    @bond_start_on_boot_with_nothing_auto
    @slaves
    @bond
    Scenario: nmcli - bond - start bond on boot - nothing auto
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0.0"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "bond0.1"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "bond0"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Disconnect device "nm-bond"
     * Reboot
     Then Check bond "nm-bond" state is "down"
     Then Check slave "eth1" not in bond "nm-bond" in proc
     Then Check slave "eth2" not in bond "nm-bond" in proc



    @bond_start_on_boot_with_one_auto_only
    @slaves
    @bond
    Scenario: nmcli - bond - start bond on boot - one slave auto only
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0.0"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "bond0.1"
     * Submit "set connection.autoconnect yes" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "bond0"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "bond0"
     * Reboot
     Then Check bond "nm-bond" state is "up"
     Then Check slave "eth1" not in bond "nm-bond" in proc
     Then Check slave "eth2" in bond "nm-bond" in proc



    @bond_start_on_boot_with_bond_and_one_slave_auto
    @slaves
    @bond
    Scenario: nmcli - bond - start bond on boot - bond and one slave auto
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0.0"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "bond0.1"
     * Submit "set connection.autoconnect yes" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "bond0"
     * Submit "set connection.autoconnect yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "bond0"
     * Bring "up" connection "bond0.0"
     * Bring "up" connection "bond0.1"
     * Reboot
     Then Check bond "nm-bond" state is "up"
     Then Check slave "eth1" not in bond "nm-bond" in proc
     Then Check slave "eth2" in bond "nm-bond" in proc



    @testcase_281170
    @slaves
    @bond
    Scenario: nmcli - bond - options - set new miimon values
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "mode=0, miimon=100, downdelay=100, updelay=100" in editor
     * Save in editor
     Then Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: load balancing \(round-robin\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"
     Then "MII Polling Interval \(ms\): 100" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "Up Delay \(ms\): 100" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "Down Delay \(ms\): 100" is visible with command "cat /proc/net/bonding/nm-bond"



    @testcase_281388
    @slaves
    @bond
    Scenario: nmcli - bond - options - set new arp values
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "mode=0, arp_interval=1000, arp_ip_target=192.168.100.1" in editor
     * Save in editor
     Then Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: load balancing \(round-robin\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"
     Then "MII Polling Interval \(ms\): 0" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "Up Delay \(ms\): 0" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "Down Delay \(ms\): 0" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "ARP Polling Interval \(ms\): 100" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "ARP IP target/s \(n.n.n.n form\): 192.168.100.1" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check "nm-bond" has "eth1" in proc
     Then Check "nm-bond" has "eth2" in proc



    @testcase_281392
    @slaves
    @bond
    Scenario: nmcli - bond - options - set conflicting values between miimon and arp
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "mode=0,miimon=100,arp_interval=1000,arp_ip_target=192.168.100.1" in editor
     * Save in editor
     Then Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: load balancing \(round-robin\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"
     Then "MII Polling Interval \(ms\): 0" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "ARP Polling Interval \(ms\): 100" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check "nm-bond" has "eth1" in proc
     Then Check "nm-bond" has "eth2" in proc



    @testcase_281393
    @bond
    Scenario: nmcli - bond - options - mode missing
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to " " in editor
     * Enter in editor
     * Save in editor
     Then Mode missing message shown in editor
     * Set a property named "bond.options" to "mode=0, miimon=100" in editor
     * Save in editor
     * Quit editor


    @testcase_281249
    @slaves
    @bond
    Scenario: nmcli - bond - options - add values
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Submit "goto bond" in editor
     * Submit "goto options" in editor
     * Submit "add miimon=100" in editor
     * Submit "add updelay=200" in editor
     * Submit "back" in editor
     * Submit "back" in editor
     * Save in editor
     When Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: load balancing \(round-robin\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"
     Then "Up Delay \(ms\): 200" is visible with command "cat /proc/net/bonding/nm-bond"


    @testcase_281558
    @bond
    Scenario: nmcli - bond - options - add incorrect value
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Open editor for connection "bond0"
     * Submit "goto bond" in editor
     * Submit "goto options" in editor
     * Submit "add modem=2" in editor
     Then Wrong bond options message shown in editor
     * Enter in editor
     * Submit "back" in editor
     * Submit "back" in editor
     * Quit editor


    @testcase_281241
    @slaves
    @bond
    Scenario: nmcli - bond - options - change values
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Submit "goto bond" in editor
     * Submit "goto options" in editor
     * Submit "change" in editor
     * Submit ", miimon=100, updelay=100" in editor
     * Submit "back" in editor
     * Submit "back" in editor
     * Save in editor
     Then Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: load balancing \(round-robin\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"
     Then "Up Delay \(ms\): 100" is visible with command "cat /proc/net/bonding/nm-bond"


    @testcase_281243
    @slaves
    @bond
    Scenario: nmcli - bond - options - remove a value
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "mode=0, miimon=100, downdelay=100, updelay=100" in editor
     * Save in editor
     Then Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: load balancing \(round-robin\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"
     Then "MII Polling Interval \(ms\): 100" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "Up Delay \(ms\): 100" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "Down Delay \(ms\): 100" is visible with command "cat /proc/net/bonding/nm-bond"
     * Open editor for connection "bond0"
     * Submit "goto bond" in editor
     * Submit "goto options" in editor
     * Submit "remove downdelay" in editor
     * Submit "back" in editor
     * Submit "back" in editor
     * Save in editor
     Then Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: load balancing \(round-robin\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"
     Then "Up Delay \(ms\): 100" is visible with command "cat /proc/net/bonding/nm-bond"
     Then "Down Delay \(ms\): 0" is visible with command "cat /proc/net/bonding/nm-bond"


    @testcase_281155
    @slaves
    @bond
    Scenario: nmcli - bond - options - overwrite some value
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "mode=0, miimon=999" in editor
     * Save in editor
     Then Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: load balancing \(round-robin\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"
     Then "MII Polling Interval \(ms\): 999" is visible with command "cat /proc/net/bonding/nm-bond"


    @testcase_280740
    @slaves
    @bond
    Scenario: nmcli - bond - options - mode set to balance-rr
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "mode=2" in editor
     * Save in editor
     When Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: load balancing \(xor\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "mode=0" in editor
     * Save in editor
     Then Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: load balancing \(round-robin\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"


    @testcase_280613
    @slaves
    @bond
    Scenario: nmcli - bond - options - mode set to active backup
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "mode=1" in editor
     * Save in editor
     When Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: fault-tolerance \(active-backup\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"


    @bond_active-backup_primary_set
    @slaves
    @bond
    Scenario: nmcli - bond - options - mode set to active backup with primary device
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "mode=active-backup,primary=eth1,miimon=100,fail_over_mac=2" in editor
     * Save in editor
     When Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: fault-tolerance \(active-backup\) \(fail_over_mac follow\)\s+Primary Slave: eth1 \(primary_reselect always\)\s+Currently Active Slave: eth1" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"


    @testcase_281146
    @slaves
    @bond
    Scenario: nmcli - bond - options - mode set to balance xor
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "mode=2" in editor
     * Save in editor
     When Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: load balancing \(xor\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"


    @testcase_281149
    @slaves
    @bond
    Scenario: nmcli - bond - options - mode set to broadcast
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "mode=3" in editor
     * Save in editor
     Then Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: fault-tolerance \(broadcast\)" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"


    @testcase_281150
    @slaves
    @bond
    Scenario: nmcli - bond - options - mode set to 802.3ad
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "mode=4" in editor
     * Save in editor
     Then Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: IEEE 802.3ad Dynamic link aggregation" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"


    @testcase_281151
    @slaves
    @bond
    Scenario: nmcli - bond - options - mode set to balance-tlb
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "miimon=100,mode=5" in editor
     * Save in editor
     Then Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: transmit load balancing" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"


    @testcase_281153
    @slaves
    @bond
    Scenario: nmcli - bond - options - mode set to balance-alb
     * Add connection type "bond" named "bond0" for device "nm-bond"
     * Add slave connection for master "nm-bond" on device "eth1" named "bond0.0"
     * Add slave connection for master "nm-bond" on device "eth2" named "bond0.1"
     * Open editor for connection "bond0"
     * Set a property named "bond.options" to "miimon=100,mode=6" in editor
     * Save in editor
     Then Value saved message showed in editor
     * Quit editor
     * Bring "up" connection "bond0"
     Then "Bonding Mode: adaptive load balancing" is visible with command "cat /proc/net/bonding/nm-bond"
     Then Check bond "nm-bond" state is "up"


#FIXME: more tests with arp and conflicts with load balancing can be written


    @testcase_281154
    @bond
    Scenario: nmcli - bond - describe bond
     * Open editor for a type "bond"
     Then Check "<<<bond>>>|=== \[options\] ===|\[NM property description\]" are present in describe output for object "bond"
     Then Check "NM property description|nmcli specific description|mode, miimon, downdelay, updelay, arp_interval, arp_ip_target|balance-rr    = 0\s+active-backup = 1\s+balance-xor   = 2\s+broadcast     = 3\s+802.3ad       = 4\s+balance-tlb   = 5\s+balance-alb   = 6" are present in describe output for object "bond.options"
      * Submit "g b" in editor
     Then Check "NM property description|nmcli specific description|mode, miimon, downdelay, updelay, arp_interval, arp_ip_target|balance-rr    = 0\s+active-backup = 1\s+balance-xor   = 2\s+broadcast     = 3\s+802.3ad       = 4\s+balance-tlb   = 5\s+balance-alb   = 6" are present in describe output for object "options"
      * Submit "g o" in editor
     Then Check "NM property description|nmcli specific description|mode, miimon, downdelay, updelay, arp_interval, arp_ip_target|balance-rr    = 0\s+active-backup = 1\s+balance-xor   = 2\s+broadcast     = 3\s+802.3ad       = 4\s+balance-tlb   = 5\s+balance-alb   = 6" are present in describe output for object " "




