 Feature: nmcli: inf

    @inf_create_connection
    @inf
    Scenario: nmcli - inf - create master connection
    * Add connection type "infiniband" named "inf" for device "inf_ib0"
    * Bring "up" connection "inf"
    Then "inet 172" is visible with command "ip a s inf_ib0"


    @inf_create_connection_novice_mode
    @inf
    Scenario: nmcli - inf - novice - create infiniband with default options
     * Open wizard for adding new connection
     * Expect "Connection type"
     * Submit "infiniband" in editor
     * Expect "Interface name"
     * Submit "inf_ib0" in editor
     * Expect "Do you want to provide them\? \(yes\/no\) \[yes\]"
     * Submit "no" in editor
     * Dismiss IP configuration in editor
     * Bring "up" connection "infiniband-inf_ib0"
    Then "inet 172" is visible with command "ip a s inf_ib0"


    @inf_disable_connection
    @inf
    Scenario: nmcli - inf - disable master connection
    * Add connection type "infiniband" named "inf" for device "inf_ib0"
    * Bring "up" connection "inf"
    * Bring "down" connection "inf"
    Then "inet 172" is not visible with command "ip a s inf_ib0"


    @inf_create_port_connection
    @inf
    Scenario: nmcli - inf - create port connection
    * Add connection type "infiniband" named "inf" for device "inf_ib0"
    * Add infiniband port named "inf.8002" for device "inf_ib0.8002" with parent "inf_ib0" and p-key "0x8002"
    * Bring "up" connection "inf"
    * Bring "up" connection "inf.8002"
    Then "inet 172" is visible with command "ip a s inf_ib0.8002"


    @inf_create_port_novice_mode
    @inf
    Scenario: nmcli - inf - novice - create infiniband port with default options
     * Add connection type "infiniband" named "inf" for device "inf_ib0"
     * Bring "up" connection "inf"
     * Open wizard for adding new connection
     * Expect "Connection type"
     * Submit "infiniband" in editor
     * Expect "Interface name"
     * Submit "inf_ib0.8002" in editor
     * Expect "Do you want to provide them\? \(yes\/no\) \[yes\]"
     * Submit "yes" in editor
     * Expect "MTU"
     * Enter in editor
     * Expect "MAC"
     * Enter in editor
     * Expect "Transport mode"
     * Enter in editor
     * Expect "Parent interface"
     * Submit "inf_ib0" in editor
     * Expect "P_KEY"
     * Submit "0x8002" in editor
     * Dismiss IP configuration in editor
     * Bring "up" connection "inf"
     * Bring "up" connection "infiniband-inf_ib0.8002"
    Then "inet 172" is visible with command "ip a s inf_ib0.8002"


    @inf_disable_port
    @inf
    Scenario: nmcli - inf - disable port connection
    * Add connection type "infiniband" named "inf" for device "inf_ib0"
    * Add infiniband port named "inf.8002" for device "inf_ib0.8002" with parent "inf_ib0" and p-key "0x8002"
    * Bring "up" connection "inf"
    * Bring "up" connection "inf.8002"
    * Bring "down" connection "inf.8002"
    Then "inet 172" is visible with command "ip a s inf_ib0"
    Then "inet 172" is not visible with command "ip a s inf_ib0.8002"


    @inf_enable_after_reboot
    @inf
    Scenario: nmcli - inf - enable after reboot
    * Add connection type "infiniband" named "inf" for device "inf_ib0"
    * Add infiniband port named "inf.8002" for device "inf_ib0.8002" with parent "inf_ib0" and p-key "0x8002"
    * Bring "up" connection "inf"
    * Bring "up" connection "inf.8002"
    * Reboot
    Then "inet 172" is visible with command "ip a s inf_ib0"
    Then "inet 172" is visible with command "ip a s inf_ib0.8002"
