 Feature: nmcli: libreswan

    @libreswan
    @libreswan_add_profile
    Scenario: nmcli - libreswan - add and connect a connection
    * Add a connection named "libreswan" for device "\*" to "libreswan" VPN
    * Use user "budulinek" with password "passwd" and group "yolo" with secret "ipsecret" for gateway "172.31.70.1" on Libreswan connection "libreswan"
    * Bring "up" connection "libreswan"
    Then "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show libreswan"
    Then "VPN.BANNER:.*BUG_REPORT_URL" is visible with command "nmcli c show libreswan"
    Then "IP4.ADDRESS.*172.31.60.2/32" is visible with command "nmcli c show libreswan"

    @libreswan
    @libreswan_terminate
    Scenario: nmcli - libreswan - terminate connection
    * Add a connection named "libreswan" for device "\*" to "libreswan" VPN
    * Use user "budulinek" with password "passwd" and group "yolo" with secret "ipsecret" for gateway "172.31.70.1" on Libreswan connection "libreswan"
    * Bring "up" connection "libreswan"
    When "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show libreswan"
    * Execute "pkill -KILL '^libreswan$'"
    Then "VPN.VPN-STATE:.*VPN connected" is not visible with command "nmcli c show libreswan" in "5" seconds
