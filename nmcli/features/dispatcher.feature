Feature: NM: dispatcher

    @dispatcher_preup_and_up
    @disp
    Scenario: NM - dispatcher - preup and up
    * Write dispatcher "99-disp" file with params "if [ "$2" == "up" ]; then sleep 15; fi"
    * Write dispatcher "pre-up.d/98-disp" file
    * Bring "up" connection "testeth1"
    Then "pre-up" is visible with command "cat /tmp/dispatcher.txt"
    Then "pre-up\s+up" is not visible with command "cat /tmp/dispatcher.txt"
    Then "pre-up\s+up" is visible with command "cat /tmp/dispatcher.txt" in "20" seconds

    @dispatcher_predown_and_down
    Scenario: NM - dispatcher - pre-down and down
    * Bring "up" connection "testeth1"
    * Write dispatcher "99-disp" file with params "if [ "$2" == "down" ]; then sleep 15; fi"
    * Write dispatcher "pre-down.d/97-disp" file
    * Bring "down" connection "testeth1"
    Then "pre-down" is visible with command "cat /tmp/dispatcher.txt"
    Then "pre-down\s+down" is not visible with command "cat /tmp/dispatcher.txt"
    Then "pre-down\s+down" is visible with command "cat /tmp/dispatcher.txt" in "20" seconds

    @dispatcher_vpn_up
    Scenario: NM - dispatcher - vpn-up

    @dispatcher_vpn_down
    Scenario: NM - dispatcher - vpn-down

    @dispatcher_hostname
    @disp
    @restore_hostname
    Scenario: NM - dispatcher - hostname
    * Write dispatcher "99-disp" file
    * Execute "nmcli general hostname walderoon"
    Then "hostname" is visible with command "cat /tmp/dispatcher.txt"

    @dispatcher_dhcp4_change
    Scenario: NM - dispatcher - dhcp4-change

    @dispatcher_dhcp6_change
    Scenario: NM - dispatcher - dhcp6-change


