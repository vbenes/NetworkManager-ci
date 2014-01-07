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
    @restart
    @testcase_290425
    Scenario: nmcli - general - state disconnected
    * Execute "nmcli device disconnect eth0"
    * Note the output of "nmcli -t -f STATE general" as value "1"
    * Note the output of "echo disconnected" as value "2"
    Then Check noted values "1" and "2" are the same
    * Execute "nmcli connection up eth0"


    @general
    @testcase_290426
    Scenario: nmcli - general - state asleep
    * Execute "nmcli network off"
    * Note the output of "nmcli -t -f STATE general" as value "1"
    * Note the output of "echo asleep" as value "2"
    Then Check noted values "1" and "2" are the same
    Then Execute "nmcli network on"


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
    * Note the output of "nmcli -t -f RUNNING general" as value "1"
    * Note the output of "echo not running" as value "2"
    Then Check noted values "1" and "2" are the same


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
    * Add a new connection of type "ethernet" and options "ifname eth0 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.10/24" in editor
    * Set a property named "ipv6.method" to "ignore" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "ip = 192.168.1.10/24" is visible with command "nmcli device show eth0"


    @general
    @testcase_294545
    Scenario: nmcli - device - show - check general params
    * Note the output of "nmcli device show eth0"
    Then Check noted output contains "GENERAL.DEVICE:\s+eth0"
    Then Check noted output contains "GENERAL.TYPE:\s+ethernet"
    Then Check noted output contains "GENERAL.IP-IFACE:\s+eth0"
    Then Check noted output contains "GENERAL.NM-MANAGED:\s+yes"
    Then Check noted output contains "GENERAL.AUTOCONNECT:\s+yes"
    Then Check noted output contains "GENERAL.VENDOR:\s+\S+\s"
    Then Check noted output contains "GENERAL.PRODUCT:\s+\S+\s"
    Then Check noted output contains "GENERAL.DRIVER:\s+\S+\s"
    Then Check noted output contains "GENERAL.DRIVER-VERSION:\s+\S+\s"
    Then Check noted output contains "GENERAL.HWADDR:\s+\S+\s"
    Then Check noted output contains "GENERAL.STATE:\s+\S+\s"
    Then Check noted output contains "GENERAL.CONNECTION:\s+\S+\s"
    Then Check noted output contains "GENERAL.FIRMWARE-MISSING:\s+\S+\s"

    @general
    @testcase_294546
    Scenario: nmcli - device - disconnect
    * "eth0\s+ethernet\s+connected" is visible with command "nmcli device"
    * Disconnect device "eth0"
    Then "eth0\s+ethernet\s+disconnected" is visible with command "nmcli device"
    * Execute "nmcli dev connect eth0"
