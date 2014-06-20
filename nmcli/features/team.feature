 Feature: nmcli: team


    @add_default_team
    @team
    Scenario: nmcli - team - add default team
     * Open editor for a type "team"
     * Submit "set team.interface-name nm-team" in editor
     * Submit "set team.connection-name nm-team" in editor
     * Save in editor
     * Enter in editor
     * Quit editor
    #Then Prompt is not running
    Then 'nm-team' is visible with command 'sudo teamdctl nm-team state dump'


    @ifcfg_team_slave_device_type
    @team
    Scenario: nmcli - team - slave ifcfg devicetype
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
    Then 'DEVICETYPE=TeamPort' is visible with command 'grep "TYPE" /etc/sysconfig/network-scripts/ifcfg-team0.0'


    @nmcli_novice_mode_create_team
    @team
    Scenario: nmcli - team - novice - create team
     * Open wizard for adding new connection
     * Expect "Connection type"
     * Submit "team" in editor
     * Expect "There is 1 optional argument"
     * Submit "no" in editor
     * Expect "Do you want to add IP addresses\? \(yes\/no\) \[yes\]"
     * Submit "no" in editor
    Then 'nm-team' is visible with command 'sudo teamdctl nm-team state dump'


    @nmcli_novice_mode_create_team-slave_with_default_options
    @team_slaves
    @team
    Scenario: nmcli - team - novice - create team-slave with default options
     * Add connection type "team" named "team0" for device "nm-team"
     * Open wizard for adding new connection
     * Expect "Connection type"
     * Submit "team-slave" in editor
     * Expect "Interface name"
     * Submit "eth1" in editor
     * Expect "Team master"
     * Submit "nm-team" in editor
     * Expect "There is 1 optional argument"
     * Submit "no" in editor
     * Bring "up" connection "team-slave-eth1"
    Then Check slave "eth1" in team "nm-team" is "up"


    @add_two_slaves_to_team
    @team_slaves
    @team
    Scenario: nmcli - team - add slaves
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Bring "up" connection "team0.0"
     * Bring "up" connection "team0.1"
    Then Check slave "eth1" in team "nm-team" is "up"
    Then Check slave "eth2" in team "nm-team" is "up"


    @add_team_master_via_uuid
    @team_slaves
    @team
    # bug verification for 1057494
    Scenario: nmcli - team - master via uuid
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "team0" on device "eth1" named "team0.0"
     * Bring "up" connection "team0.0"
    Then Check slave "eth1" in team "nm-team" is "up"


    @remove_all_slaves
    @team_slaves
    @team
    Scenario: nmcli - team - remove last slave
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Bring "up" connection "team0.0"
     * Delete connection "team0.0"
    Then Check slave "eth1" in team "nm-team" is "down"



    @remove_one_slave
    @team_slaves
    @team
    Scenario: nmcli - team - remove a slave
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Bring "up" connection "team0.1"
     * Bring "up" connection "team0.0"
     * Delete connection "team0.1"
    Then Check slave "eth1" in team "nm-team" is "up"
    Then Check slave "eth2" in team "nm-team" is "down"



    @change_slave_type_and_master
    @team_slaves
    @team
    Scenario: nmcli - connection - slave-type and master settings
     * Add connection type "team" named "team0" for device "nm-team"
     * Add connection type "ethernet" named "team0.0" for device "eth1"
     * Open editor for connection "team0.0"
     * Set a property named "connection.slave-type" to "team" in editor
     * Set a property named "connection.master" to "nm-team" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "team0.0"
    Then Check slave "eth1" in team "nm-team" is "up"



    @remove_active_team_profile
    @team_slaves
    @team
    Scenario: nmcli - team - remove active team profile
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Bring "up" connection "team0.0"
    Then Check slave "eth1" in team "nm-team" is "up"
     * Delete connection "team0"
    Then Team "nm-team" is down


    @disconnect_active_team
    @team_slaves
    @team
    Scenario: nmcli - team - disconnect active team
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Bring "up" connection "team0"
     * Disconnect device "nm-team"
    Then Team "nm-team" is down


    @team_start_by_hand_no_slaves
    @team_slaves
    @team
    Scenario: nmcli - team - start team by hand with no slaves
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Disconnect device "nm-team"
     * Bring "down" connection "team0.0"
     * Bring "down" connection "team0.1"
    Then Team "nm-team" is down
     * Bring up connection "team0" ignoring error
    Then 'nm-team' is visible with command 'sudo teamdctl nm-team state dump'


    @start_team_by_hand_all_auto
    @team_slaves
    @team
    Scenario: nmcli - team - start team by hand with all auto
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Disconnect device "nm-team"
     * Bring "down" connection "team0.0"
     * Bring "down" connection "team0.1"
    Then Team "nm-team" is down
     * Bring "up" connection "team0.0"
     * Bring "up" connection "team0.1"
    Then Check slave "eth1" in team "nm-team" is "up"
    Then Check slave "eth2" in team "nm-team" is "up"


    @team_activate
    @team_slaves
    @team
    Scenario: nmcli - team - activate
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Disconnect device "nm-team"
     * Bring "down" connection "team0.0"
     * Bring "down" connection "team0.1"
    Then Team "nm-team" is down
     * Open editor for connection "team0.0"
     * Submit "activate" in editor
     * Enter in editor
     * Save in editor
     * Quit editor
    Then Check slave "eth1" in team "nm-team" is "up"
    Then Check slave "eth2" in team "nm-team" is "down"


    @start_team_by_hand_one_auto
    @team_slaves
    @team
    Scenario: nmcli - team - start team by hand with one auto
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Open editor for connection "team0.0"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "team0.0"
     * Bring "up" connection "team0.1"
     * Bring "up" connection "team0"
    Then Check slave "eth1" in team "nm-team" is "down"
    Then Check slave "eth2" in team "nm-team" is "up"


    @start_team_on_boot
    @team_slaves
    @team
    Scenario: nmcli - team - start team on boot
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Open editor for connection "team0"
     * Submit "set connection.autoconnect yes" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "team0.0"
     * Submit "set connection.autoconnect yes" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "team0.1"
     * Submit "set connection.autoconnect yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "team0"
     * Reboot
    Then Check slave "eth1" in team "nm-team" is "up"
    Then Check slave "eth2" in team "nm-team" is "up"


    @team_start_on_boot_with_nothing_auto
    @team_slaves
    @team
    Scenario: nmcli - team - start team on boot - nothing auto
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Open editor for connection "team0.0"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "team0.1"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "team0"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Bring up connection "team0" ignoring error
     * Bring "up" connection "team0.0"
     * Bring "up" connection "team0.1"
     * Reboot
    Then Team "nm-team" is down


    #VVV    THIS IS DIFFERENT IN BOND AREA

    @team_start_on_boot_with_one_auto_only
    @team_slaves
    @team
    Scenario: nmcli - team - start team on boot - one slave auto only
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Open editor for connection "team0.0"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "team0.1"
     * Submit "set connection.autoconnect yes" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "team0"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "team0"
     * Reboot
    Then Check slave "eth2" in team "nm-team" is "up"
    Then Check slave "eth1" in team "nm-team" is "down"


    @team_start_on_boot_with_team_and_one_slave_auto
    @team_slaves
    @team
    Scenario: nmcli - team - start team on boot - team and one slave auto
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Open editor for connection "team0.0"
     * Submit "set connection.autoconnect no" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "team0.1"
     * Submit "set connection.autoconnect yes" in editor
     * Save in editor
     * Quit editor
     * Open editor for connection "team0"
     * Submit "set connection.autoconnect yes" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "team0"
     * Reboot
    Then Check slave "eth2" in team "nm-team" is "up"
    Then Check slave "eth1" in team "nm-team" is "down"


    @config_loadbalance
    @team_slaves
    @team
    Scenario: nmcli - team - config - set loadbalance mode
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Open editor for connection "team0"
     * Submit "set team.config {\"device\":\"nm-team\",\"runner\":{\"name\":\"loadbalance\"},\"ports\":{\"eth1\":{},\"eth2\": {}}}" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "team0"
    Then '"kernel_team_mode_name": "loadbalance"' is visible with command 'sudo teamdctl nm-team state dump'
    Then Check slave "eth1" in team "nm-team" is "up"
    Then Check slave "eth2" in team "nm-team" is "up"


    # @config_lacp
    # @team_slaves
    # @team
    # Scenario: nmcli - team - config - set lacp mode
    #  * Add connection type "team" named "team0" for device "nm-team"
    #  * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
    #  * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
    #  * Open editor for connection "team0"
    #  * Submit "set team.config {"device":"nm-team","runner":{"name":"lacp","active":true,"fast_rate":true,"tx_hash":["eth","ipv4","ipv6"]},"link_watch":{"name": "ethtool"},"ports":{"eth1":{},"eth2":{}}}" in editor
    #  * Save in editor
    #  * Quit editor
    #  * Bring "up" connection "team0"
    #  #* Bring "up" connection "team0.0"
    #  #* Bring "up" connection "team0.1"
    # Then '"runner_name": "lacp"' is visible with command 'sudo teamdctl nm-team state dump'
    # Then Check slave "eth1" in team "nm-team" is "up"
    # Then Check slave "eth2" in team "nm-team" is "up"


    @config_broadcast
    @team_slaves
    @team
    Scenario: nmcli - team - config - set broadcast mode
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Open editor for connection "team0"
     * Submit "set team.config {    \"device\":       \"nm-team\",  \"runner\":       {\"name": \"broadcast\"},  \"ports\":        {\"eth1\": {}, \"eth2\": {}}}" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "team0"
    Then '"kernel_team_mode_name": "broadcast"' is visible with command 'sudo teamdctl nm-team state dump'
    Then Check slave "eth1" in team "nm-team" is "up"
    Then Check slave "eth2" in team "nm-team" is "up"



    @config_invalid
    @team_slaves
    @team
    @clean
    Scenario: nmcli - team - config - set invalid mode
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Open editor for connection "team0"
     * Submit "set team.config {blah blah blah}" in editor
     * Save in editor
     * Quit editor
     * Bring up connection "team0" ignoring error
    Then Team "nm-team" is down


    @remove_config
    @team_slaves
    @team
    Scenario: nmcli - team - config - remove
     * Add connection type "team" named "team0" for device "nm-team"
     * Add slave connection for master "nm-team" on device "eth1" named "team0.0"
     * Add slave connection for master "nm-team" on device "eth2" named "team0.1"
     * Bring "up" connection "team0.0"
     * Bring "up" connection "team0.1"
     * Open editor for connection "team0"
     * Submit "set team.config {\"device\":\"nm-team\",\"runner\":{\"name\":\"loadbalance\"},\"ports\":{\"eth1\":{},\"eth2\": {}}}" in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "team0"
     * Bring "up" connection "team0.0"
     * Bring "up" connection "team0.1"
    Then '"kernel_team_mode_name": "loadbalance"' is visible with command 'sudo teamdctl nm-team state dump'
    Then Check slave "eth1" in team "nm-team" is "up"
    Then Check slave "eth2" in team "nm-team" is "up"
     * Open editor for connection "team0"
     * Submit "set team.config" in editor
     * Enter in editor
     * Save in editor
     * Quit editor
     * Bring "up" connection "team0"
    Then '"kernel_team_mode_name": "loadbalance"' is not visible with command 'sudo teamdctl nm-team state dump'
    Then Check slave "eth1" in team "nm-team" is "up"
    Then Check slave "eth2" in team "nm-team" is "up"


    @describe
    @team
    Scenario: nmcli - team - describe team
     * Open editor for a type "team"
     Then Check "=== \[interface-name\]|\[NM property description\]|=== \[config\] ===|\[NM property description\]" are present in describe output for object "team"
     Then Check "JSON configuration for the team network interface. The property should contain raw JSON configuration data suitable for teamd, because the value is passed directly to teamd. If not specified, the default configuration is used. See man teamd.conf for the format details." are present in describe output for object "bond.options"
     Then Check "=== \[interface-name\] ===|\[NM property description\]|The name of the virtual in-kernel team network interface" are present in describe output for object "team.interface-name"
      * Submit "g t" in editor
     Then Check "NM property description|JSON configuration for the team network interface. The property should contain raw JSON configuration data suitable for teamd, because the value is passed directly to teamd. If not specified, the default configuration is used. See man teamd.conf for the format details." are present in describe output for object "config"
     Then Check "\[interface-name\]|\[NM property description\]|The name of the virtual in-kernel team network interface" are present in describe output for object "interface-name"
      * Submit "g c" in editor
     Then Check "JSON configuration for the team network interface. The property should contain raw JSON configuration data suitable for teamd, because the value is passed directly to teamd. If not specified, the default configuration is used. See man teamd.conf for the format details." are present in describe output for object " "

