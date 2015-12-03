 Feature: nmcli: libreswan

    @libreswan
    @libreswan_add_profile
    Scenario: nmcli - libreswan - add and connect a connection
    * Add a connection named "libreswan" for device "\*" to "libreswan" VPN
    * Use user "budulinek" with password "passwd" and group "yolo" with secret "ipsecret" for gateway "172.31.70.1" on Libreswan connection "libreswan"
    * Bring "up" connection "libreswan"
    Then "172.31.80.0/24 dev racoon1" is visible with command "ip route"
    Then "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show libreswan"
    Then "VPN.BANNER:.*BUG_REPORT_URL" is visible with command "nmcli c show libreswan"
    Then "IP4.ADDRESS.*172.31.60.2/32" is visible with command "nmcli c show libreswan"
    Then "IP4.ADDRESS.*172.31.60.2/32" is visible with command "nmcli d show racoon1"
    Then "IP4.ADDRESS.*172.31.70.*/24" is visible with command "nmcli d show racoon1"
    Then "IP4.GATEWAY:.*172.31.70.1" is visible with command "nmcli d show racoon1"


    @rhbz1250723
    @libreswan
    @libreswan_connection_renewal
    Scenario: NM - libreswan - main connection lifetime renewal
    * Add a connection named "libreswan" for device "\*" to "libreswan" VPN
    * Use user "budulinek" with password "passwd" and group "yolo" with secret "ipsecret" for gateway "172.31.70.1" on Libreswan connection "libreswan"
    * Bring "up" connection "libreswan"
    Then "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show libreswan" for full "130" seconds
    Then "172.31.80.0/24 dev racoon1" is visible with command "ip route"
    Then "VPN.BANNER:.*BUG_REPORT_URL" is visible with command "nmcli c show libreswan"
    Then "IP4.ADDRESS.*172.31.60.2/32" is visible with command "nmcli c show libreswan"
    Then "IP4.ADDRESS.*172.31.60.2/32" is visible with command "nmcli d show racoon1"
    Then "IP4.ADDRESS.*172.31.70.*/24" is visible with command "nmcli d show racoon1"
    Then "IP4.GATEWAY:.*172.31.70.1" is visible with command "nmcli d show racoon1"

    # @libreswan
    # @vpn_add_profile_novice_mode
    # Scenario: nmcli - vpn - novice mode - add default connection


    # @libreswan
    # @vpn_activate_asking_for_credentials
    # Scenario: nmcli - vpn - activate asking for password


    @libreswan
    @libreswan_terminate
    Scenario: nmcli - libreswan - terminate connection
    * Add a connection named "libreswan" for device "\*" to "libreswan" VPN
    * Use user "budulinek" with password "passwd" and group "yolo" with secret "ipsecret" for gateway "172.31.70.1" on Libreswan connection "libreswan"
    * Bring "up" connection "libreswan"
    When "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show libreswan"
    * Bring "down" connection "libreswan"
    Then "VPN.VPN-STATE:.*VPN connected" is not visible with command "nmcli c show libreswan" in "10" seconds


    @libreswan
    @libreswan_delete_active_profile
    Scenario: nmcli - libreswan - delete active profile
    * Add a connection named "libreswan" for device "\*" to "libreswan" VPN
    * Use user "budulinek" with password "passwd" and group "yolo" with secret "ipsecret" for gateway "172.31.70.1" on Libreswan connection "libreswan"
    * Bring "up" connection "libreswan"
    When "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show libreswan"
    * Delete connection "libreswan"
    Then "VPN.VPN-STATE:.*VPN connected" is not visible with command "nmcli c show libreswan" in "10" seconds
    Then "172.31.80.0/24 dev racoon1" is not visible with command "ip route" in "10" seconds


    #@libreswan
    #@ethernet
    #@libreswan_start_on_boot
    #Scenario: nmcli - libreswan - start on boot
    # * Add a connection named "libreswan" for device "\*" to "libreswan" VPN
    # * Execute "nmcli con modify eno1 connection.autoconnect no"
    # * Use user "budulinek" with password "passwd" and group "yolo" with secret "ipsecret" for gateway "172.31.70.1" on Libreswan connection "libreswan"
    # * Reboot
    # * "libreswan" is visible with command "nmcli con show -a" in "10" seconds
    # Then "172.31.80.0/24 dev racoon1" is visible with command "ip route"
    # Then "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show libreswan"
    # Then "VPN.BANNER:.*BUG_REPORT_URL" is visible with command "nmcli c show libreswan"
    # Then "IP4.ADDRESS.*172.31.60.2/32" is visible with command "nmcli c show libreswan"
    # Then "IP4.ADDRESS.*172.31.60.2/32" is visible with command "nmcli d show racoon1"
    # Then "IP4.ADDRESS.*172.31.70.2/24" is visible with command "nmcli d show racoon1"
    # Then "IP4.GATEWAY:.*172.31.70.1" is visible with command "nmcli d show racoon1"
    # Then Ping "10.16.40.254"


    @libreswan
    @libreswan_start_as_secondary
    Scenario: nmcli - libreswan - start as secondary
    * Add a connection named "libreswan" for device "\*" to "libreswan" VPN
    * Use user "budulinek" with password "passwd" and group "yolo" with secret "ipsecret" for gateway "172.31.70.1" on Libreswan connection "libreswan"
    * Execute "nmcli con modify rac1 connection.secondaries libreswan"
    #* Bring "down" connection "rac1"
    #* Execute "ip link set dev racoon1 up"
    * Bring "up" connection "rac1"
    Then "libreswan" is visible with command "nmcli con show -a" in "60" seconds
    Then "rac1" is visible with command "nmcli con show -a" in "60" seconds
    Then "172.31.80.0/24 dev racoon1" is visible with command "ip route"
    Then "VPN.VPN-STATE:.*VPN connected" is visible with command "nmcli c show libreswan"
    Then "VPN.BANNER:.*BUG_REPORT_URL" is visible with command "nmcli c show libreswan"
    Then "IP4.ADDRESS.*172.31.60.2/32" is visible with command "nmcli c show libreswan"
    Then "IP4.ADDRESS.*172.31.60.2/32" is visible with command "nmcli d show racoon1"
    Then "IP4.ADDRESS.*172.31.70.*/24" is visible with command "nmcli d show racoon1"
    Then "IP4.GATEWAY:.*172.31.70.1" is visible with command "nmcli d show racoon1"


    @vpn_describe
    Scenario: nmcli - vpn - describe
    * Open editor for a type "vpn"
    When Check "<<< vpn >>>|=== \[service-type\] ===\s+\[NM property description\]\s+D-Bus service name of the VPN plugin that this setting uses to connect to its network.  i.e. org.freedesktop.NetworkManager.vpnc for the vpnc plugin.\s+=== \[user-name\] ===\s+\[NM property description\]\s+If the VPN connection requires a user name for authentication, that name should be provided here.  If the connection is available to more than one user, and the VPN requires each user to supply a different name, then leave this property empty.  If this property is empty, NetworkManager will automatically supply the username of the user which requested the VPN connection.\s+=== \[persistent\] ===\s+\[NM property description\]\s+If the VPN service supports persistence, and this property is TRUE, the VPN will attempt to stay connected across link changes and outages, until explicitly disconnected.\s+=== \[data\] ===\s+\[NM property description\]\s+Dictionary of key/value pairs of VPN plugin specific data.  Both keys and values must be strings.\s+=== \[secrets\] ===\s+\[NM property description\]\s+Dictionary of key\/value pairs of VPN plugin specific secrets like passwords or private keys.\s+Both keys and values must be strings." are present in describe output for object "vpn"


    @rhbz1060460
    @vpn
    @vpn_keep_username_from_data
    Scenario: nmcli - vpn - keep username from vpn.data
    * Add a new connection of type "vpn" and options "ifname \* con-name vpn autoconnect no vpn-type libreswan"
    * Open editor for connection "vpn"
    * Submit "set vpn.service-type org.freedesktop.NetworkManager.libreswan" in editor
    * Submit "set vpn.data right = ciscovpn.idm.lab.bos.redhat.com, xauthpasswordinputmodes = save, xauthpassword-flags = 1, esp = aes-sha1;modp1024, leftxauthusername = desktopqe, pskinputmodes = save, ike = aes-sha1;modp1024, pskvalue-flags = 1, leftid = desktopqe" in editor
    * Save in editor
    * Submit "set vpn.user-name incorrectuser"
    * Save in editor
    * Quit editor
    Then "leftxauthusername=desktopqe" is visible with command "cat /etc/NetworkManager/system-connections/vpn"
    Then "user-name=incorrectuser" is visible with command "cat /etc/NetworkManager/system-connections/vpn"