@testplan
Feature: nmcli - ppp

    # Please do use tags as follows:
    # @bugzilla_link (rhbz123456)
    # @version_control (ver+/-=1.4.1)
    # @other_tags (see environment.py)
    # @test_name (compiled from scenario name)
    # Scenario:

    @not_on_s390x @pppoe @del_test1112_veths
    @connect_to_pppoe_via_pap
    Scenario: NM - ppp - connect with pap auth
    * Execute "ip link add test11 type veth peer name test12"
    * Prepare pppoe server for user "test" with "networkmanager" password and IP "192.168.111.2" authenticated via "pap"
    * Start pppoe server with "isp" and IP "192.168.111.254" on device "test12"
    * Add a new connection of type "pppoe" and options "con-name ppp ifname test11 service isp username test password networkmanager"
    * Execute "ip link set dev test11 up"
    * Bring "up" connection "ppp"
    Then "nameserver 8.8.8.8" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
    Then "inet 192.168.111.2 peer 192.168.111.254/32 .*scope global ppp" is visible with command "ip a s"
    Then "inet 192.168.111.254 peer 192.168.111.2/32 .*scope global ppp" is visible with command "ip a s"
    Then "192.168.111.2 dev ppp.*\s+proto kernel\s+scope link\s+src 192.168.111.254" is visible with command "ip r"
    Then "default via 192.168.111.254 dev ppp.*\s+proto static\s+metric" is visible with command "ip r"


    @not_on_s390x @pppoe @del_test1112_veths
    @connect_to_pppoe_via_chap
   Scenario: NM - ppp - connect with chap auth
    * Execute "ip link add test11 type veth peer name test12"
    * Prepare pppoe server for user "test" with "networkmanager" password and IP "192.168.111.2" authenticated via "chap"
    * Start pppoe server with "isp" and IP "192.168.111.254" on device "test12"
    * Add a new connection of type "pppoe" and options "con-name ppp ifname test11 service isp username test password networkmanager"
    * Execute "ip link set dev test11 up"
    * Bring "up" connection "ppp"
    Then "nameserver 8.8.8.8" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
    Then "inet 192.168.111.2 peer 192.168.111.254/32 .*scope global ppp" is visible with command "ip a s"
    Then "inet 192.168.111.254 peer 192.168.111.2/32 .*scope global ppp" is visible with command "ip a s"
    Then "192.168.111.2 dev ppp.*\s+proto kernel\s+scope link\s+src 192.168.111.254" is visible with command "ip r"
    Then "default via 192.168.111.254 dev ppp.*\s+proto static\s+metric" is visible with command "ip r"


    @not_on_s390x @pppoe @del_test1112_veths
    @disconnect_from_pppoe
    Scenario: NM - ppp - disconnect
    * Execute "ip link add test11 type veth peer name test12"
    * Prepare pppoe server for user "test" with "networkmanager" password and IP "192.168.111.2" authenticated via "chap"
    * Start pppoe server with "isp" and IP "192.168.111.254" on device "test12"
    * Add a new connection of type "pppoe" and options "con-name ppp ifname test11 service isp username test password networkmanager"
    * Execute "ip link set dev test11 up"
    * Bring "up" connection "ppp"
    * Bring "down" connection "ppp"
    Then "nameserver 8.8.8.8" is not visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is not visible with command "cat /etc/resolv.conf"
    Then "inet 192.168.111.2 peer 192.168.111.254/32 scope global ppp" is not visible with command "ip a s"
    Then "default via 192.168.111.254 dev ppp.*\s+proto static\s+metric" is not visible with command "ip r"


    @rhbz1110465
    @ver+=1.4.0
    @not_on_s390x @pppoe @del_test1112_veths @firewall
    @update_firewall_zone_upon_reconnect
    Scenario: NM - ppp - firewall zone update upon reconnect
    * Execute "ip link add test11 type veth peer name test12"
    * Prepare pppoe server for user "test" with "networkmanager" password and IP "192.168.111.2" authenticated via "pap"
    * Start pppoe server with "isp" and IP "192.168.111.254" on device "test12"
    * Add a new connection of type "pppoe" and options "con-name ppp ifname test11 service isp username test password networkmanager"
    * Execute "nmcli connection modify ppp connection.zone external"
    * Execute "ip link set dev test11 up"
    * Bring "up" connection "ppp"
    When "external" is visible with command "firewall-cmd --get-zone-of-interface=ppp0" in "10" seconds
     And "external" is visible with command "firewall-cmd --get-zone-of-interface=test11" in "10" seconds
     And "nameserver 8.8.8.8" is visible with command "cat /etc/resolv.conf"
     And "nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
     And "inet 192.168.111.2 peer 192.168.111.254/32 .*scope global ppp" is visible with command "ip a s"
     And "inet 192.168.111.254 peer 192.168.111.2/32 .*scope global ppp" is visible with command "ip a s"
     And "192.168.111.2 dev ppp.*\s+proto kernel\s+scope link\s+src 192.168.111.254" is visible with command "ip r"
     And "default via 192.168.111.254 dev ppp.*\s+proto static\s+metric" is visible with command "ip r"
    * Execute "ip link set dev test12 down && sleep 2 && ip link set dev test12 up"
    Then "external" is visible with command "firewall-cmd --get-zone-of-interface=ppp0" in "10" seconds
     And "external" is visible with command "firewall-cmd --get-zone-of-interface=test11" in "10" seconds
     And "nameserver 8.8.8.8" is visible with command "cat /etc/resolv.conf"
     And "nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
     And "inet 192.168.111.2 peer 192.168.111.254/32 .*scope global ppp" is visible with command "ip a s"
     And "inet 192.168.111.254 peer 192.168.111.2/32 .*scope global ppp" is visible with command "ip a s"
     And "192.168.111.2 dev ppp.*\s+proto kernel\s+scope link\s+src 192.168.111.254" is visible with command "ip r"
     And "default via 192.168.111.254 dev ppp.*\s+proto static\s+metric" is visible with command "ip r"

    @rhbz1478694
    @ver+=1.9.1
    @not_on_s390x @pppoe @del_test1112_veths
    @pppoe_over_vlan
    Scenario: NM - ppp - pppoe over vlan
    * Execute "ip link add test11 type veth peer name test12"
    * Execute "ip link set test11 up"
    * Execute "ip link set test12 up"
    * Execute "ip link add link test11 vlan1 type vlan id 51"
    * Execute "ip link add link test12 vlan2 type vlan id 51"
    * Execute "ip link set vlan1 up"
    * Execute "ip link set vlan2 up"
    * Prepare pppoe server for user "test" with "networkmanager" password and IP "192.168.111.2" authenticated via "pap"
    * Start pppoe server with "isp" and IP "192.168.111.254" on device "vlan1"
    * Add a new connection of type "pppoe" and options "con-name ppp ifname my-ppp pppoe.parent vlan2 service isp username test password networkmanager autoconnect no"
    * Bring "up" connection "ppp"
    Then "inet 192.168.111.2 peer 192.168.111.254/32" is visible with command "ip a s my-ppp"
    And "default via 192.168.111.254 dev my-ppp" is visible with command "ip r"
