 Feature: nmcli: vpn

    @vpn_add_profile
    Scenario: nmcli - vpn - add default connection
    * Add connection for a type "vpn" named "vpn" for device "\*"
    * Open editor for connection "vpn"
    * Submit "set vpn.service-type org.freedesktop.NetworkManager.libreswan" in editor
    * Submit "set vpn.data right = ciscovpn.idm.lab.bos.redhat.com, xauthpasswordinputmodes = save, Domain = redhat.com, xauthpassword-flags = 1, esp = aes128-sha1, leftxauthusername = desktopqe, pskinputmodes = save, ike = aes128-sha1, pskvalue-flags = 1, leftid = desktopqe" in editor
    * Save in editor
    * Quit editor
<<<<<<< HEAD
    * Bring "up" connection "vpn"
=======
    * Bring up connection "vpn" ignoring error
    Then "Received IPv4 address: 192.168.99." is visible with command "sudo tail -n 20 /var/log/messages"
    Then "Received IP4 NETMASK 255.255.255.0" is visible with command "sudo tail -n 20 /var/log/messages"
    Then "Received DNS 8.8.8.8" is visible with command "sudo tail -n 20 /var/log/messages"
    Then "Received DNS 8.8.4.4" is visible with command "sudo tail -n 20 /var/log/messages"
>>>>>>> 0eedc42... sync with old repo

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

    @vpn_describe
    Scenario: nmcli - vpn - describe


