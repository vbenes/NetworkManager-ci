 Feature: nmcli: openvpn

    @openvpn
    @openvpn_add_profile
    Scenario: nmcli - openvpn - add and connect a connection
    * Add a connection named "openvpn" for device "\*" to "openvpn" VPN
    * Use certificate "sample-keys/client.crt" with key "sample-keys/client.key" and authority "sample-keys/ca.crt" for gateway "127.0.0.1" on OpenVPN connection "openvpn"
    * Bring "up" connection "openvpn"
    Then "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show openvpn"
    Then "IP4.ADDRESS.*172.31.70.*/32" is visible with command "nmcli c show openvpn"

    @openvpn
    @openvpn_terminate
    Scenario: nmcli - openvpn - terminate connection
    * Add a connection named "openvpn" for device "\*" to "openvpn" VPN
    * Use certificate "sample-keys/client.crt" with key "sample-keys/client.key" and authority "sample-keys/ca.crt" for gateway "127.0.0.1" on OpenVPN connection "openvpn"
    * Execute "nmcli c modify openvpn vpn.persistent true"
    * Bring "up" connection "openvpn"
    When "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show openvpn"
    * Execute "pkill -KILL -f 'openvpn.*nm-openvpn-service-openvpn-helper'"
    Then "VPN.VPN-STATE:.*VPN connected" is not visible with command "nmcli c show openvpn" in "5" seconds

    @openvpn
    @openvpn_persist
    Scenario: nmcli - openvpn - persist connection
    * Add a connection named "openvpn" for device "\*" to "openvpn" VPN
    * Use certificate "sample-keys/client.crt" with key "sample-keys/client.key" and authority "sample-keys/ca.crt" for gateway "127.0.0.1" on OpenVPN connection "openvpn"
    * Bring "up" connection "openvpn"
    When "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show openvpn"
    * Execute "systemctl restart openvpn@trest-server"
    * Execute "sleep 3"
    Then "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show openvpn"
