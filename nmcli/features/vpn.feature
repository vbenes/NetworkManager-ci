 Feature: nmcli: vpn

    @vpn_add_profile
    @vpn
    Scenario: nmcli - vpn - add default connection
    * Add a new connection of type "vpn" and options "ifname \* con-name vpn vpn-type libreswan"
    * Open editor for connection "vpn"
    * Submit "set vpn.service-type org.freedesktop.NetworkManager.libreswan" in editor
    * Submit "set vpn.data right = ciscovpn.idm.lab.bos.redhat.com, xauthpasswordinputmodes = save, xauthpassword-flags = 1, esp = aes-sha1;modp1024, leftxauthusername = desktopqe, pskinputmodes = save, ike = aes-sha1;modp1024, pskvalue-flags = 1, leftid = desktopqe" in editor
    * Save in editor
    * Quit editor
    Then "vpn.service-type:\s+org.freedesktop.NetworkManager.libreswan" is visible with command "nmcli connection show vpn"

    @vpn_add_profile_novice_mode
    Scenario: nmcli - vpn - novice mode - add default connection

    @vpn_activate_with_stored_credentials
    Scenario: nmcli - vpn - activate with stored credentials

    @vpn_activate_asking_for_credentials
    Scenario: nmcli - vpn - activate asking for password

    @vpn_deactivate
    Scenario: nmcli - vpn - deactivate

    @vpn_delete_active_profile
    Scenario: nmcli - vpn - delete active profile

    @vpn_start_on_boot
    Scenario: nmcli - vpn - start on boot

    @vpn_start_as_secondary
    Scenario: nmcli - vpn - start as secondary

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
