 Feature: nmcli: alias

    @alias_ifcfg_add_single_alias
    @alias
    Scenario: ifcfg - alias - add single alias
    * Add connection type "ethernet" named "eth7" for device "eth7"
    * Open editor for connection "eth7"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 192.168.0.100/24" in editor
    * Submit "set ipv4.gateway 192.168.0.1" in editor
    * Save in editor
    * Quit editor

    * Append "DEVICE='eth7:0'" to ifcfg file "eth7:0"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:0"
    * Append "IPADDR=192.168.0.101" to ifcfg file "eth7:0"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:0"
    * Finish "sudo nmcli connection reload"
    * Bring "up" connection "eth7"

    Then "inet 192.168.0.101" is visible with command "ip a s eth7"
    Then "inet 192.168.0.100" is visible with command "ip a s eth7"

    @alias_ifcfg_add_multiple_aliases
    @alias
    Scenario: ifcfg - alias - add mutliple aliases
    * Add connection type "ethernet" named "eth7" for device "eth7"
    * Open editor for connection "eth7"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 192.168.0.100/24" in editor
    * Submit "set ipv4.gateway 192.168.0.1" in editor
    * Save in editor
    * Quit editor

    * Append "DEVICE='eth7:0'" to ifcfg file "eth7:0"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:0"
    * Append "IPADDR=192.168.0.101" to ifcfg file "eth7:0"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:0"

    * Append "DEVICE='eth7:1'" to ifcfg file "eth7:1"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:1"
    * Append "IPADDR=192.168.0.102" to ifcfg file "eth7:1"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:1"

    * Append "DEVICE='eth7:2'" to ifcfg file "eth7:2"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:2"
    * Append "IPADDR=192.168.0.103" to ifcfg file "eth7:2"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:2"

    * Finish "sudo nmcli connection reload"
    * Bring "up" connection "eth7"

    Then "inet 192.168.0.100" is visible with command "ip a s eth7"
    Then "inet 192.168.0.101" is visible with command "ip a s eth7"
    Then "inet 192.168.0.102" is visible with command "ip a s eth7"
    Then "inet 192.168.0.103" is visible with command "ip a s eth7"


    @alias_ifcfg_connection_restart
    @alias
    Scenario: ifcfg - alias - connection restart
    * Add connection type "ethernet" named "eth7" for device "eth7"
    * Open editor for connection "eth7"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 192.168.0.100/24" in editor
    * Submit "set ipv4.gateway 192.168.0.1" in editor
    * Save in editor
    * Quit editor

    * Append "DEVICE='eth7:0'" to ifcfg file "eth7:0"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:0"
    * Append "IPADDR=192.168.0.101" to ifcfg file "eth7:0"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:0"

    * Append "DEVICE='eth7:1'" to ifcfg file "eth7:1"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:1"
    * Append "IPADDR=192.168.0.102" to ifcfg file "eth7:1"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:1"

    * Append "DEVICE='eth7:2'" to ifcfg file "eth7:2"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:2"
    * Append "IPADDR=192.168.0.103" to ifcfg file "eth7:2"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:2"

    * Finish "sudo nmcli connection reload"
    * Bring "up" connection "eth7"
    * Bring "down" connection "eth7"
    * Bring "up" connection "eth7"

    Then "inet 192.168.0.100" is visible with command "ip a s eth7"
    Then "inet 192.168.0.101" is visible with command "ip a s eth7"
    Then "inet 192.168.0.102" is visible with command "ip a s eth7"
    Then "inet 192.168.0.103" is visible with command "ip a s eth7"


    @alias_ifcfg_remove_single_alias
    @alias
    Scenario: ifcfg - alias - remove single alias
    * Add connection type "ethernet" named "eth7" for device "eth7"
    * Open editor for connection "eth7"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 192.168.0.100/24" in editor
    * Submit "set ipv4.gateway 192.168.0.1" in editor
    * Save in editor
    * Quit editor

    * Append "DEVICE='eth7:0'" to ifcfg file "eth7:0"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:0"
    * Append "IPADDR=192.168.0.101" to ifcfg file "eth7:0"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:0"

    * Append "DEVICE='eth7:1'" to ifcfg file "eth7:1"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:1"
    * Append "IPADDR=192.168.0.102" to ifcfg file "eth7:1"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:1"

    * Append "DEVICE='eth7:2'" to ifcfg file "eth7:2"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:2"
    * Append "IPADDR=192.168.0.103" to ifcfg file "eth7:2"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:2"

    * Finish "sudo nmcli connection reload"
    * Bring "up" connection "eth7"
    * Run child "sudo rm -f /etc/sysconfig/network-scripts/ifcfg-eth7:0"
    * Finish "sudo nmcli connection reload"
    * Bring "up" connection "eth7"

    Then "inet 192.168.0.100" is visible with command "ip a s eth7"
    Then "inet 192.168.0.101" is not visible with command "ip a s eth7"
    Then "inet 192.168.0.102" is visible with command "ip a s eth7"
    Then "inet 192.168.0.103" is visible with command "ip a s eth7"


    @alias_ifcfg_remove_all_aliases
    @alias
    Scenario: ifcfg - alias - remove all aliases
    * Add connection type "ethernet" named "eth7" for device "eth7"
    * Open editor for connection "eth7"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 192.168.0.100/24" in editor
    * Submit "set ipv4.gateway 192.168.0.1" in editor
    * Save in editor
    * Quit editor

    * Append "DEVICE='eth7:0'" to ifcfg file "eth7:0"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:0"
    * Append "IPADDR=192.168.0.101" to ifcfg file "eth7:0"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:0"

    * Append "DEVICE='eth7:1'" to ifcfg file "eth7:1"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:1"
    * Append "IPADDR=192.168.0.102" to ifcfg file "eth7:1"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:1"

    * Append "DEVICE='eth7:2'" to ifcfg file "eth7:2"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:2"
    * Append "IPADDR=192.168.0.103" to ifcfg file "eth7:2"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:2"

    * Finish "sudo nmcli connection reload"
    * Bring "up" connection "eth7"
    * Run child "sudo rm -f /etc/sysconfig/network-scripts/ifcfg-eth7:0"
    * Run child "sudo rm -f /etc/sysconfig/network-scripts/ifcfg-eth7:1"
    * Run child "sudo rm -f /etc/sysconfig/network-scripts/ifcfg-eth7:2"
    * Finish "sudo nmcli connection reload"
    * Bring "up" connection "eth7"

    Then "inet 192.168.0.100" is visible with command "ip a s eth7"
    Then "inet 192.168.0.101" is not visible with command "ip a s eth7"
    Then "inet 192.168.0.102" is not visible with command "ip a s eth7"
    Then "inet 192.168.0.103" is not visible with command "ip a s eth7"


    @alias_ifcfg_reboot
    @veth
    @alias
    Scenario: ifcfg - alias - reboot
    * Add connection type "ethernet" named "eth7" for device "eth7"
    * Open editor for connection "eth7"
    * Submit "set ipv4.method manual" in editor
    * Submit "set ipv4.addresses 192.168.0.100/24" in editor
    * Submit "set ipv4.gateway 192.168.0.1" in editor
    * Save in editor
    * Quit editor

    * Append "DEVICE='eth7:0'" to ifcfg file "eth7:0"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:0"
    * Append "IPADDR=192.168.0.101" to ifcfg file "eth7:0"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:0"

    * Append "DEVICE='eth7:1'" to ifcfg file "eth7:1"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:1"
    * Append "IPADDR=192.168.0.102" to ifcfg file "eth7:1"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:1"

    * Append "DEVICE='eth7:2'" to ifcfg file "eth7:2"
    * Append "GATEWAY=192.168.0.1" to ifcfg file "eth7:2"
    * Append "IPADDR=192.168.0.103" to ifcfg file "eth7:2"
    * Append "NETMASK=255.255.255.0" to ifcfg file "eth7:2"

    * Finish "sudo nmcli connection reload"
    * Bring "up" connection "eth7"
    * Reboot

    Then "inet 192.168.0.100" is visible with command "ip a s eth7"
    Then "inet 192.168.0.101" is visible with command "ip a s eth7"
    Then "inet 192.168.0.102" is visible with command "ip a s eth7"
    Then "inet 192.168.0.103" is visible with command "ip a s eth7"

