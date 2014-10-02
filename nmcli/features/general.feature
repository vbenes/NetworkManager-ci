@testplan
Feature: nmcli - general

 # Background:
 #   * Close Evolution and cleanup data
    @general
    @testcase_290423
    Scenario: nmcli - general - check version
    * Note the output of "rpm -q --queryformat '%{VERSION}' NetworkManager" as value "1"
    * Note the output of "nmcli -t -f VERSION general" as value "2"
    Then Check noted values "1" and "2" are the same


    @general
    @testcase_290424
    Scenario: nmcli - general - state connected
    * Note the output of "nmcli -t -f STATE general" as value "1"
    * Note the output of "echo connected" as value "2"
    Then Check noted values "1" and "2" are the same

    @general
    @hostname_change
    Scenario: nmcli - general - set hostname
    * Execute "sudo nmcli general hostname walderon"
    Then "walderon" is visible with command "cat /etc/hostname"


    @general
    @restart
    @testcase_290425
    Scenario: nmcli - general - state disconnected
    * "disconnect" all " connected" devices
    * Note the output of "nmcli -t -f STATE general" as value "1"
    * Note the output of "echo disconnected" as value "2"
    Then Check noted values "1" and "2" are the same
    * Bring up connection "eth0"


    @general
    @testcase_290426
    Scenario: nmcli - general - state asleep
    * Execute "nmcli networking off"
    * Note the output of "nmcli -t -f STATE general" as value "1"
    * Note the output of "echo asleep" as value "2"
    Then Check noted values "1" and "2" are the same
    Then Execute "nmcli networking on"


    @general
    @testcase_290427
    Scenario: nmcli - general - running
    * Note the output of "nmcli -t -f RUNNING general" as value "1"
    * Note the output of "echo running" as value "2"
    Then Check noted values "1" and "2" are the same


    @general
    @restart
    @testcase_290428
    Scenario: nmcli - general - not running
    * Execute "sudo service NetworkManager stop"
    * Wait for at least "2" seconds
    Then "NetworkManager is not running" is visible with command "nmcli general"


    @general
    @testcase_290429
    Scenario: nmcli - general - networking
    * Note the output of "nmcli -t -f NETWORKING general" as value "1"
    * Note the output of "echo enabled" as value "2"
    Then Check noted values "1" and "2" are the same
    * Execute "nmcli networking off"
    * Note the output of "nmcli -t -f NETWORKING general" as value "3"
    * Note the output of "echo disabled" as value "4"
    Then Check noted values "3" and "4" are the same
    Then Execute "nmcli networking on"


    @general
    @testcase_290430
    Scenario: nmcli - networking - status - enabled
    * Note the output of "nmcli networking" as value "1"
    * Note the output of "echo enabled" as value "2"
    Then Check noted values "1" and "2" are the same


    @general
    @testcase_290431
    Scenario: nmcli - networking - status - disabled
    * Note the output of "nmcli networking" as value "1"
    * Note the output of "echo enabled" as value "2"
    * Check noted values "1" and "2" are the same
    * Execute "nmcli networking off"
    * Note the output of "nmcli networking" as value "3"
    * Note the output of "echo disabled" as value "4"
    Then Check noted values "3" and "4" are the same
    Then Execute "nmcli networking on"


    @general
    @testcase_290432
    Scenario: nmcli - networking - turn off
    * "eth0:" is visible with command "ifconfig"
    * Execute "nmcli networking off"
    Then "eth0:" is not visible with command "ifconfig"
    Then Execute "nmcli networking on"


    @general
    @testcase_290433
    Scenario: nmcli - networking - turn on
    * Execute "nmcli networking off"
    * "eth0:" is not visible with command "ifconfig"
    * Execute "nmcli networking on"
    Then "eth0:" is visible with command "ifconfig"


    @general
    @testcase_294542
    Scenario: nmcli - radio - status
    Then "WIFI-HW\s+WIFI\s+WWAN-HW\s+WWAN\s+enabled|disabled\s+enabled|disabled\s+enabled|disabled\s+enabled|disabled" is visible with command "nmcli radio"


    @general
    @testcase_294543
    Scenario: nmcli - device - status
    Then "DEVICE\s+TYPE\s+STATE.+eth0\s+ethernet" is visible with command "nmcli device"


    @general
    @ethernet
    @testcase_2945544
    Scenario: nmcli - device - show - check ip
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.10/24" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "ip = 192.168.1.10/24" is visible with command "nmcli device show eth1"


    @general
    @testcase_294545
    Scenario: nmcli - device - show - check general params
    * Note the output of "nmcli device show eth0"
    Then Check noted output contains "GENERAL.DEVICE:\s+eth0"
    Then Check noted output contains "GENERAL.TYPE:\s+ethernet"
    Then Check noted output contains "GENERAL.MTU:\s+[0-9]+"
    Then Check noted output contains "GENERAL.HWADDR:\s+\S+:\S+:\S+:\S+:\S+:\S+"
    Then Check noted output contains "GENERAL.CON-PATH:\s+\S+\s"
    Then Check noted output contains "GENERAL.CONNECTION:\s+\S+\s"

    @general
    @testcase_294546
    Scenario: nmcli - device - disconnect
    * "eth0\s+ethernet\s+connected" is visible with command "nmcli device"
    * Disconnect device "eth0"
    Then "eth0\s+ethernet\s+disconnected" is visible with command "nmcli device"
    * Execute "nmcli dev connect eth0"


## Basically various bug related reproducer tests follow here


    @general
    @ethernet
    @device_connect
    Scenario: nmcli - device - connect
    * "eth2\s+ethernet\s+disconnected" is visible with command "nmcli device"
    * Connect device "eth2"
    Then "eth2\s+ethernet\s+connected" is visible with command "nmcli device"
    * Execute "nmcli dev disconnect eth2"


    #bz1034150
    @general
    @bridge
    @nmcli_device_delete
    Scenario: nmcli - device - delete
    * Add a new connection of type "bridge" and options "ifname bridge0 con-name bridge0"
    * "bridge0\s+bridge" is visible with command "nmcli device"
    * Execute "nmcli device delete bridge0"
    Then "bridge0\s+bridge" is not visible with command "nmcli device"
    Then "bridge0" is visible with command "nmcli connection"


    #bz1034150
    @general
    @nmcli_device_attempt_hw_delete
    Scenario: nmcli - device - attempt to delete hw interface
    * "eth9\s+ethernet" is visible with command "nmcli device"
    Then "Error" is visible with command "nmcli device delete eth9"
    Then "eth9\s+ethernet" is visible with command "nmcli device"


    #bz1067712
    @general
    @ethernet
    @nmcli_general_correct_profile_activated_after_restart
    Scenario: nmcli - general - correct profile activated after restart
    * Bring down connection "eth9" ignoring error
    * Add a new connection of type "ethernet" and options "ifname eth9 con-name aaa"
    * Add a new connection of type "ethernet" and options "ifname eth9 con-name bbb"
    * Bring up connection "aaa"
    * Restart NM
    Then "bbb" is not visible with command "nmcli device"
    Then "aaa" is visible with command "nmcli device"


    #bz1007365
    @general
    @bridge
    @nmcli_novice_mode_readline
    Scenario: nmcli - general - using readline library in novice mode
    * Open wizard for adding new connection
    * Expect "Connection type"
    * Send "bond" in editor
    * Clear the text typed in editor
    * Submit "bridge" in editor
    Then Expect "arguments for 'bridge' connection"


    @general
    @dns_none
    Scenario: NM - dns none setting
    * Execute "sudo sed -i 's/plugins=ifcfg-rh/plugins=ifcfg-rh\ndns=none/' /etc/NetworkManager/NetworkManager.conf"
    * Execute "sudo echo 'nameserver 1.2.3.4' > /etc/resolv.conf"
    * Execute "cat /etc/resolv.conf"
    * Restart NM
    * Bring "up" connection "eth0"
    Then "nameserver 1.2.3.4" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 10" is not visible with command "cat /etc/resolv.conf"

    @general
    @remove_dns_none
    Scenario: NM - dns  none removal
    When "nameserver 1.2.3.4" is visible with command "cat /etc/resolv.conf"
    * Execute "sudo sed -i 's/dns=none/\n/' /etc/NetworkManager/NetworkManager.conf"
    * Restart NM
    * Bring "up" connection "eth0"
    Then "nameserver 1.2.3.4" is not visible with command "cat /etc/resolv.conf"
    Then "nameserver 10" is visible with command "cat /etc/resolv.conf"

