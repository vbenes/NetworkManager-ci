 Feature: nmcli: dcb

    @dcb_enable_connection
    @dcb
    Scenario: nmcli - dcb - enable connection
    * Add connection type "ethernet" named "dcb" for device "enp4s0f0"
    * Open editor for connection "dcb"
    * Prepare connection
    * Set default DCB options
    * Save in editor
    * Quit editor
    * Bring "up" connection "dcb"

    # dcb on
    Then "DCB State:\s+on" is visible with command "dcbtool gc enp4s0f0 dcb"

    # priority groups
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc enp4s0f0 pg"
    Then "up2tc:\s+0\s+0\s+0\s+0\s+1\s+1\s+1\s+1" is visible with command "dcbtool gc enp4s0f0 pg"
    Then "pgpct:\s+13\%\s+13\%\s+13\%\s+13\%\s+12\%\s+12\%\s+12\%\s+12\%" is visible with command "dcbtool gc enp4s0f0 pg"
    Then "uppct:\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%" is visible with command "dcbtool gc enp4s0f0 pg"

    # priority flow control
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc enp4s0f0 pfc"
    Then "pfcup:\s+1\s+0\s+0\s+1\s+1\s+0\s+1\s+0" is visible with command "dcbtool gc enp4s0f0 pfc"

     # apps
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc enp4s0f0 app:fcoe"
    Then "appcfg:\s+80" is visible with command "dcbtool gc enp4s0f0 app:fcoe"
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc enp4s0f0 app:iscsi"
    Then "appcfg:\s+40" is visible with command "dcbtool gc enp4s0f0 app:iscsi"
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc enp4s0f0 app:fip"
    Then "appcfg:\s+04" is visible with command "dcbtool gc enp4s0f0 app:fip"


    @dcb_disable_connection
    @dcb
    Scenario: nmcli - dcb - disable connection
    * Add connection type "ethernet" named "dcb" for device "enp4s0f0"
    * Open editor for connection "dcb"
    * Prepare connection
    * Set default DCB options
    * Save in editor
    * Quit editor
    * Bring "up" connection "dcb"
    * Disconnect device "enp4s0f0"
    * Finish "sleep 5"
    # dcb off
    Then "DCB State:\s+off" is visible with command "dcbtool gc enp4s0f0 dcb"
    Then "Enable:\s+false" is visible with command "dcbtool gc enp4s0f0 pg"
    Then "Enable:\s+false" is visible with command "dcbtool gc enp4s0f0 pfc"
    Then "Enable:\s+false" is visible with command "dcbtool gc enp4s0f0 app:fcoe"
    Then "Enable:\s+false" is visible with command "dcbtool gc enp4s0f0 app:iscsi"
    Then "Enable:\s+false" is visible with command "dcbtool gc enp4s0f0 app:fip"


    @dcb_enable_after_reboot
    @dcb
    Scenario: nmcli - dcb - enable after reboot
    * Add connection type "ethernet" named "dcb" for device "enp4s0f0"
    * Open editor for connection "dcb"
    * Prepare connection
    * Set default DCB options
    * Save in editor
    * Quit editor
    * Bring "up" connection "dcb"
    * Reboot
    # dcb on
    Then "DCB State:\s+on" is visible with command "dcbtool gc enp4s0f0 dcb"

    # priority groups
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc enp4s0f0 pg"
    Then "up2tc:\s+0\s+0\s+0\s+0\s+1\s+1\s+1\s+1" is visible with command "dcbtool gc enp4s0f0 pg"
    Then "pgpct:\s+13\%\s+13\%\s+13\%\s+13\%\s+12\%\s+12\%\s+12\%\s+12\%" is visible with command "dcbtool gc enp4s0f0 pg"
    Then "uppct:\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%\s+100\%" is visible with command "dcbtool gc enp4s0f0 pg"

    # priority flow control
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc enp4s0f0 pfc"
    Then "pfcup:\s+1\s+0\s+0\s+1\s+1\s+0\s+1\s+0" is visible with command "dcbtool gc enp4s0f0 pfc"

     # apps
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc enp4s0f0 app:fcoe"
    Then "appcfg:\s+80" is visible with command "dcbtool gc enp4s0f0 app:fcoe"
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc enp4s0f0 app:iscsi"
    Then "appcfg:\s+40" is visible with command "dcbtool gc enp4s0f0 app:iscsi"
    Then "Enable:\s+true\s+Advertise:\s+true\s+Willing:\s+true" is visible with command "dcbtool gc enp4s0f0 app:fip"
    Then "appcfg:\s+04" is visible with command "dcbtool gc enp4s0f0 app:fip"


    # https://bugzilla.redhat.com/show_bug.cgi?id=1080510
    @dcb_error_shown
    @dcb
    Scenario: nmcli - dcb - error shown
    * Add connection type "ethernet" named "dcb" for device "enp4s0f0"
    * Open editor for connection "dcb"
    * Prepare connection
    * Set default DCB options
    * Submit "set dcb.app-fcoe-priority 8" in editor
    Then Error type "failed to set 'app-fcoe-priority' property: '8' is not valid; use <-1-7>" shown in editor
