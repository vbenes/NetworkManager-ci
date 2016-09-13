 Feature: nmcli: dcb

    @dcb_enable_connection
    @dcb
    Scenario: nmcli - dcb - enable connection
    * Add a new connection of type "ethernet" and options "ifname ens1f0 con-name dcb ipv4.addresses 1.2.3.4/24 ipv4.method manual"
    #* Open editor for connection "dcb"
    * Prepare connection
    * Set default DCB options
    #* Save in editor
    #* Quit editor
    * Bring "up" connection "dcb"
    # dcb on
    Then "DCB State:\s+on" is visible with command "dcbtool gc ens1f0 dcb"

    # priority groups
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc ens1f0 pg"
    Then "up2tc:\s+0\s+0\s+0\s+0\s+1\s+1\s+1\s+1" is visible with command "dcbtool gc ens1f0 pg"
    Then "pgpct:\s+13\%\s+13\%\s+13\%\s+13\%\s+12\%\s+12\%\s+12\%\s+12\%" is visible with command "dcbtool gc ens1f0 pg"
    Then "uppct:\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%" is visible with command "dcbtool gc ens1f0 pg"

    # priority flow control
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc ens1f0 pfc"
    Then "pfcup:\s+1\s+0\s+0\s+1\s+1\s+0\s+1\s+0" is visible with command "dcbtool gc ens1f0 pfc"

     # apps
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc ens1f0 app:fcoe"
    Then "appcfg:\s+80" is visible with command "dcbtool gc ens1f0 app:fcoe"
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc ens1f0 app:iscsi"
    Then "appcfg:\s+40" is visible with command "dcbtool gc ens1f0 app:iscsi"
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc ens1f0 app:fip"
    Then "appcfg:\s+04" is visible with command "dcbtool gc ens1f0 app:fip"


    @dcb_disable_connection
    @dcb
    Scenario: nmcli - dcb - disable connection
    * Add a new connection of type "ethernet" and options "ifname ens1f0 con-name dcb ipv4.addresses 1.2.3.4/24 ipv4.method manual"
    #* Open editor for connection "dcb"
    * Prepare connection
    * Set default DCB options
    #* Save in editor
    #* Quit editor
    * Bring "up" connection "dcb"
    * Disconnect device "ens1f0"
    # dcb off
    #Then "DCB State:\s+off" is visible with command "dcbtool gc ens1f0 dcb"
    Then "Enable:\s+false" is visible with command "dcbtool gc ens1f0 pg" in "5" seconds
    Then "Enable:\s+false" is visible with command "dcbtool gc ens1f0 pfc"
    Then "Enable:\s+false" is visible with command "dcbtool gc ens1f0 app:fcoe"
    Then "Enable:\s+false" is visible with command "dcbtool gc ens1f0 app:iscsi"
    Then "Enable:\s+false" is visible with command "dcbtool gc ens1f0 app:fip"


    @dcb_enable_after_reboot
    @dcb
    Scenario: nmcli - dcb - enable after reboot
    * Add a new connection of type "ethernet" and options "ifname ens1f0 con-name dcb ipv4.addresses 1.2.3.4/24 ipv4.method manual"
    * Prepare connection
    * Set default DCB options
    * Bring "up" connection "dcb"
    * Reboot
    # dcb on
    Then "DCB State:\s+on" is visible with command "dcbtool gc ens1f0 dcb"

    # priority groups
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc ens1f0 pg"
    Then "up2tc:\s+0\s+0\s+0\s+0\s+1\s+1\s+1\s+1" is visible with command "dcbtool gc ens1f0 pg"
    Then "pgpct:\s+13\%\s+13\%\s+13\%\s+13\%\s+12\%\s+12\%\s+12\%\s+12\%" is visible with command "dcbtool gc ens1f0 pg"
    Then "uppct:\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%" is visible with command "dcbtool gc ens1f0 pg"

    # priority flow control
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc ens1f0 pfc"
    Then "pfcup:\s+1\s+0\s+0\s+1\s+1\s+0\s+1\s+0" is visible with command "dcbtool gc ens1f0 pfc"

     # apps
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc ens1f0 app:fcoe"
    Then "appcfg:\s+80" is visible with command "dcbtool gc ens1f0 app:fcoe"
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc ens1f0 app:iscsi"
    Then "appcfg:\s+40" is visible with command "dcbtool gc ens1f0 app:iscsi"
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc ens1f0 app:fip"
    Then "appcfg:\s+04" is visible with command "dcbtool gc ens1f0 app:fip"


    @rhbz1080510
    @dcb_error_shown
    @dcb
    Scenario: nmcli - dcb - error shown
    * Add connection type "ethernet" named "dcb" for device "ens1f0"
    * Open editor for connection "dcb"
    * Prepare connection
    * Set default DCB options
    * Submit "set dcb.app-fcoe-priority 8" in editor
    Then Error type "failed to set 'app-fcoe-priority' property: '8' is not valid; use <-1-7>" shown in editor
