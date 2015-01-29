Feature: NM: dispatcher

    @dispatcher_preup_and_up
    @disp
    @rhbz982633
    Scenario: NM - dispatcher - preup and up
    * Write dispatcher "99-disp" file with params "if [ "$2" == "up" ]; then sleep 15; fi"
    * Write dispatcher "pre-up.d/98-disp" file
    * Bring "up" connection "testeth1"
    Then "pre-up" is visible with command "cat /tmp/dispatcher.txt"
    Then "pre-up\s+up" is not visible with command "cat /tmp/dispatcher.txt"
    Then "pre-up\s+up" is visible with command "cat /tmp/dispatcher.txt" in "20" seconds

    @dispatcher_predown_and_down
    @disp
    @rhbz982633
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


    @dispatcher_synchronicity
    @disp
    @rhbz1048345
    Scenario: NM - dispatcher - synchronicity
    * Write dispatcher "98-disp" file with params "if [ "$2" == "up" ]; then sleep 30; fi"
    * Write dispatcher "99-disp" file
    * Bring "up" connection "testeth1"
    * Bring "down" connection "testeth1"
    Then "up" is not visible with command "cat /tmp/dispatcher.txt"
    Then "up\s+up\s+down" is visible with command "cat /tmp/dispatcher.txt" in "30" seconds


    @dispatcher_synchronicity_with_predown
    @disp
    @rhbz1048345
    Scenario: NM - dispatcher - synchronicity with predown
    * Write dispatcher "98-disp" file with params "if [ "$2" == "up" ]; then sleep 30; fi"
    * Write dispatcher "99-disp" file
    * Write dispatcher "pre-down.d/97-disp" file
    * Bring "up" connection "testeth1"
    * Bring down connection "testeth1" ignoring error
    Then "up" is not visible with command "cat /tmp/dispatcher.txt"
    Then "up\s+up\s+pre-down\s+down" is visible with command "cat /tmp/dispatcher.txt" in "30" seconds


    @dispatcher_serialization
    @disp
    @rhbz1061212
    Scenario: NM - dispatcher - serialization
    * Bring "down" connection "testeth1"
    * Bring "down" connection "testeth2"
    * Write dispatcher "98-disp" file with params "if [ "$2" == "up" ]; then sleep 30; echo $1 >> /tmp/dispatcher.txt; fi"
    * Write dispatcher "99-disp" file with params "if [ "$2" == "up" ]; then echo "quick$1" >> /tmp/dispatcher.txt; fi"
    * Bring "up" connection "testeth1"
    * Bring "up" connection "testeth2"
    #Then "eth1\s+up" is not visible with command "cat /tmp/dispatcher.txt"
    #Then "eth2\s+up" is not visible with command "cat /tmp/dispatcher.txt"
    Then "eth1\s+up\s+quicketh1\s+up\s+eth2\s+up\s+quicketh2\s+up" is visible with command "cat /tmp/dispatcher.txt" in "50" seconds



