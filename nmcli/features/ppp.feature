@testplan
Feature: nmcli - ppp

    @not_on_s390x
    @connect_to_pppoe_via_pap
    @pppoe
    @del_test1112_veths
    Scenario: NM - ppp - connect with pap auth
    * Execute "ip link add test11 type veth peer name test12"
    * Prepare pppoe server for user "test" with "redhat" password and IP "192.168.111.2" authenticated via "pap"
    * Start pppoe server with "isp" and IP "192.168.111.254" on device "test12"
    * Add a new connection of type "pppoe" and options "con-name ppp ifname test11 service isp username test password redhat"
    * Execute "ip link set dev test11 up"
    * Bring "up" connection "ppp"
    Then "nameserver 8.8.8.8" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
    Then "inet 192.168.111.2 peer 192.168.111.254/32 .*scope global ppp" is visible with command "ip a s"
    Then "inet 192.168.111.254 peer 192.168.111.2/32 .*scope global ppp" is visible with command "ip a s"
    Then "192.168.111.2 dev ppp.*  proto kernel  scope link  src 192.168.111.254" is visible with command "ip r"
    Then "default via 192.168.111.254 dev ppp.*  proto static  metric" is visible with command "ip r"


    @not_on_s390x
    @connect_to_pppoe_via_chap
    @pppoe
    @del_test1112_veths
    Scenario: NM - ppp - connect with chap auth
    * Execute "ip link add test11 type veth peer name test12"
    * Prepare pppoe server for user "test" with "redhat" password and IP "192.168.111.2" authenticated via "chap"
    * Start pppoe server with "isp" and IP "192.168.111.254" on device "test12"
    * Add a new connection of type "pppoe" and options "con-name ppp ifname test11 service isp username test password redhat"
    * Execute "ip link set dev test11 up"
    * Bring "up" connection "ppp"
    Then "nameserver 8.8.8.8" is visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is visible with command "cat /etc/resolv.conf"
    Then "inet 192.168.111.2 peer 192.168.111.254/32 .*scope global ppp" is visible with command "ip a s"
    Then "inet 192.168.111.254 peer 192.168.111.2/32 .*scope global ppp" is visible with command "ip a s"
    Then "192.168.111.2 dev ppp.*  proto kernel  scope link  src 192.168.111.254" is visible with command "ip r"
    Then "default via 192.168.111.254 dev ppp.*  proto static  metric" is visible with command "ip r"


    @not_on_s390x
    @disconnect_from_pppoe
    @pppoe
    @del_test1112_veths
    Scenario: NM - ppp - disconnect
    * Execute "ip link add test11 type veth peer name test12"
    * Prepare pppoe server for user "test" with "redhat" password and IP "192.168.111.2" authenticated via "chap"
    * Start pppoe server with "isp" and IP "192.168.111.254" on device "test12"
    * Add a new connection of type "pppoe" and options "con-name ppp ifname test11 service isp username test password redhat"
    * Execute "ip link set dev test11 up"
    * Bring "up" connection "ppp"
    * Bring "down" connection "ppp"
    Then "nameserver 8.8.8.8" is not visible with command "cat /etc/resolv.conf"
    Then "nameserver 8.8.4.4" is not visible with command "cat /etc/resolv.conf"
    Then "inet 192.168.111.2 peer 192.168.111.254/32 scope global ppp" is not visible with command "ip a s"
    Then "default via 192.168.111.254 dev ppp.*  proto static  metric" is not visible with command "ip r"

