 Feature: nmcli: vpnc

    @vpnc
    @vpnc_add_profile
    Scenario: nmcli - vpnc - add and connect a connection
    * Add a connection named "vpnc" for device "\*" to "vpnc" VPN
    * Use user "budulinek" with password "passwd" and group "yolo" with secret "ipsecret" for gateway "172.31.70.1" on VPNC connection "vpnc"
    * Bring "up" connection "vpnc"
    Then "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show vpnc"
    Then "VPN.BANNER:.*BUG_REPORT_URL" is visible with command "nmcli c show vpnc"
    Then "IP4.ADDRESS.*172.31.60.2/24" is visible with command "nmcli c show vpnc"

    @vpnc
    @vpnc_terminate
    Scenario: nmcli - vpnc - terminate connection
    * Add a connection named "vpnc" for device "\*" to "vpnc" VPN
    * Use user "budulinek" with password "passwd" and group "yolo" with secret "ipsecret" for gateway "172.31.70.1" on VPNC connection "vpnc"
    * Bring "up" connection "vpnc"
    When "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show vpnc"
    * Execute "pkill -KILL '^vpnc$'"
    Then "VPN.VPN-STATE:.*VPN connected" is not visible with command "nmcli c show vpnc" in "5" seconds
