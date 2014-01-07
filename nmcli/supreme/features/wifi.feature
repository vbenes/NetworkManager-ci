@testplan
Feature: nmcli - wifi

 # Background:
 #   * Close Evolution and cleanup data

	@cleanwifi
    Scenario: Clean wifi
    * Execute "echo nada"


    @wifi
    @testcase_306548
    Scenario: nmcli - wifi - connect to WPA2 PSK network without profile
    * Connect wifi device to "qe-wpa2-psk" network with options "password 'over the river and through the woods'"
    Then "\*\s+qe-wpa2-psk" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    Then "qe-wpa2-psk" is visible with command "iw dev wlan0 link"


    @wifi
    @testcase_306549
    Scenario: nmcli - wifi - connect to WPA1 PSK network without profile
    * Connect wifi device to "qe-wpa1-psk" network with options "password 'over the river and through the woods'"
    Then "\*\s+qe-wpa1-psk" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    Then "qe-wpa1-psk" is visible with command "iw dev wlan0 link"


    @wifi
    @testcase_306550
    Scenario: nmcli - wifi - connect to open network without profile
    * Connect wifi device to "qe-open" network
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    Then "qe-open" is visible with command "iw dev wlan0 link"


    @wifi
    @testcase_306551
    Scenario: nmcli - wifi - connect to WEP hex-key network without profile
    * Connect wifi device to "qe-wep" network with options "password 74657374696E67313233343536 wep-key-type key"
    Then "\*\s+qe-wep" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    Then "qe-wep" is visible with command "iw dev wlan0 link"


    @wifi
    @testcase_309707
    Scenario: nmcli - wifi - connect to WEP ascii-key network without profile
    * Connect wifi device to "qe-wep" network with options "password testing123456 wep-key-type key"
    Then "\*\s+qe-wep" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    Then "qe-wep" is visible with command "iw dev wlan0 link"


    @wifi
    @testcase_306552
    Scenario: nmcli - wifi - connect to WEP phrase network without profile
    * Connect wifi device to "qe-wep-psk" network with options "password testing123456 wep-key-type phrase"
    Then "\*\s+qe-wep" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    Then "qe-wep" is visible with command "iw dev wlan0 link"


    @wifi
    @testcase_306553
    Scenario: nmcli - wifi - create a new connection for an open network
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect on ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Wait for at least "5" seconds
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    Then "qe-open" is visible with command "iw dev wlan0 link"


    @wifi
    @testcase_306554
    Scenario: nmcli - wifi - connection up for an open network
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Bring up connection "qe-open"
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    Then "qe-open" is visible with command "iw dev wlan0 link"


    @wifi
    @testcase_306555
    Scenario: nmcli - wifi - connection down for an open network
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Bring up connection "qe-open"
    * "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    * "qe-open" is visible with command "iw dev wlan0 link"
    * Bring down connection "qe-open"
    Then "\*\s+qe-open" is not visible with command "nmcli -f IN-USE,SSID device wifi list"
    Then "qe-open" is not visible with command "iw dev wlan0 link"


    @wifi
    @testcase_306556
    Scenario: nmcli - wifi - infrastructure mode setting
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.mode" to "infrastructure" in editor
    * Save in editor
    * Check value saved message showed in editor
    * No error appeared in editor
    * Quit editor
    * Bring up connection "qe-open"
    Then "qe-open" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_306557
    Scenario: nmcli - wifi - adhoc open network
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-adhoc autoconnect off ssid qe-adhoc"
    * Check ifcfg-name file created for connection "qe-adhoc"
    * Open editor for connection "qe-adhoc"
    * Set a property named "802-11-wireless.mode" to "adhoc" in editor
    * Set a property named "ipv4.method" to "shared" in editor
    * Set a property named "ipv6.method" to "auto" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Execute "nmcli connection up qe-adhoc"
    * Wait for at least "3" seconds
    Then "qe-adhoc" is visible with command "iw dev wlan0 link"
    Then "Joined IBSS" is visible with command "iw dev wlan0 link"


    @wifi
    @testcase_306558
    Scenario: nmcli - wifi - right band
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.band" to "bg" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-open"
    Then "qe-open" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_306559
    Scenario: nmcli - wifi - different than network's band
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.band" to "a" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-open"
    Then "qe-open" is not visible with command "iw dev wlan0 link"
    Then "\*\s+qe-open" is not visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_306560
    Scenario: nmcli - wifi - setting bogus band
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.band" to "x" in editor
    Then See Error while saving in editor
    * Quit editor


    @wifi
    @testcase_306561
    Scenario: nmcli - wifi - setting wrong SSID (over 32 bytes)
    * Open editor for a type "wifi"
    * Set a property named "802-11-wireless.ssid" to "hsdkfjhsdkjfhskjdhfkdsjhfkjshkjagdgdsfsjkdhf" in editor
    Then See Error while saving in editor
    * Quit editor


    @wifi
    @testcase_306562
    Scenario: nmcli - wifi - set channel
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.band" to "bg" in editor
    * Set a property named "802-11-wireless.channel" to "7" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-open"
    Then "qe-open" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_306563
    Scenario: nmcli - wifi - set channel < 7 (bz 999999)
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.band" to "bg" in editor
    * Set a property named "802-11-wireless.channel" to "1" in editor
    * Set a property named "802-11-wireless.channel" to "2" in editor
    * Set a property named "802-11-wireless.channel" to "3" in editor
    * Set a property named "802-11-wireless.channel" to "4" in editor
    * Set a property named "802-11-wireless.channel" to "5" in editor
    * Set a property named "802-11-wireless.channel" to "6" in editor
    Then No error appeared in editor
    * Save in editor
    * Quit editor


    @wifi
    @testcase_306564
    Scenario: nmcli - wifi - set channel 13 and 14 (bz 999999)
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.band" to "bg" in editor
    * Set a property named "802-11-wireless.channel" to "13" in editor
    * Set a property named "802-11-wireless.channel" to "14" in editor
    Then No error appeared in editor
    * Save in editor
    * Quit editor


    @wifi
    @testcase_306565
    Scenario: nmcli - wifi - set wrong channel
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.band" to "bg" in editor
    * Set a property named "802-11-wireless.channel" to "11" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    Then "Error" is visible with command "nmcli connection up qe-open"
    Then "\*\s+qe-open" is not visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_306566
    Scenario: nmcli - wifi - set bogus channel
    * Open editor for a type "wifi"
    * Set a property named "802-11-wireless.channel" to "15" in editor
    Then See Error while saving in editor
    * Quit editor


    @wifi
    @testcase_306567
    Scenario: nmcli - wifi - set non-existent bssid
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.bssid" to "00:11:22:33:44:55" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    Then "Error" is visible with command "nmcli connection up qe-open"
    Then "\*\s+qe-open" is not visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_306568
    Scenario: nmcli - wifi - set bogus bssid
    * Open editor for a type "wifi"
    * Set a property named "802-11-wireless.bssid" to "dough" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.bssid" to "00:13:DG:7F:54:CF" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.bssid" to "00:13:DA:7F:54" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.bssid" to "00:13:DA:7F:54:CF:AA" in editor
    Then Error appeared in editor
    * Quit editor


    @wifi
    @testcase_306569
    Scenario: nmcli - wifi - set existing bssid
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Bring up connection "qe-open"
    * Bring down connection "qe-open"
    * Open editor for connection "qe-open"
    * Note the "802-11-wireless.seen-bssids" property from editor print output
    * Set a property named "802-11-wireless.bssid" to "noted-value" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-open"
    Then "qe-open" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"

    @wifi
    @testcase_306570
    Scenario: nmcli - wifi - check rate configuration
    * Open editor for a type "wifi"
    * Set a property named "802-11-wireless.rate" to "5500" in editor
    Then Error appeared in editor
    * Quit editor


    @wifi
    @testcase_306571
    Scenario: nmcli - wifi - check txpower configuration
    * Open editor for a type "wifi"
    * Set a property named "802-11-wireless.tx-power" to "5" in editor
    Then Error appeared in editor
    * Quit editor


    @wifi
    @testcase_306572
    Scenario: nmcli - wifi - set bogus txpower
    * Open editor for a type "wifi"
    * Set a property named "802-11-wireless.rate" to "-1" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.rate" to "valderon" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.rate" to "9999999999" in editor
    Then Error appeared in editor
    * Quit editor


    @wifi
    @testcase_306573
    Scenario: nmcli - wifi - set bogus rate
    * Open editor for a type "wifi"
    * Set a property named "802-11-wireless.rate" to "-5" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.rate" to "krobot" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.rate" to "9999999999" in editor
    Then Error appeared in editor
    * Quit editor


    @wifi
    @testcase_306574
    Scenario: nmcli - wifi - set matching mac adress
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Note the "ether" property from ifconfig output for device "wlan0"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.mac-address" to "noted-value" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-open"
    Then "qe-open" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_306575
    Scenario: nmcli - wifi - set non-existent mac adress
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.mac-address" to "00:11:22:33:44:55" in editor
    * Save in editor
    * Check value saved message showed in editor
    * No error appeared in editor
    * Quit editor
    Then "no device found" is visible with command "nmcli connection up qe-open"


    @wifi
    @testcase_306576
    Scenario: nmcli - wifi - set bogus mac adress
    * Open editor for a type "wifi"
    * Set a property named "802-11-wireless.mac-address" to "-1" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.mac-address" to "4294967297" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.mac-address" to "ooops" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.mac-address" to "00:13:DG:7F:54:CF" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.mac-address" to "00:13:DA:7F:54" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.mac-address" to "00:13:DA:7F:54:CF:AA" in editor
    Then Error appeared in editor
    * Quit editor


    @wifi
    @testcase_306577
    Scenario: nmcli - wifi - set mac adress in dashed format (bz 1002553)
    * Open editor for a type "wifi"
    * Set a property named "802-11-wireless.mac-address" to "00-11-22-33-44-55" in editor
    Then No error appeared in editor

    @wifi
    @testcase_306578
    Scenario: nmcli - wifi - mac spoofing (if hw supported)
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.cloned-mac-address" to "f0:de:aa:fb:bb:cc" in editor
    * Save in editor
    * Check value saved message showed in editor
    * No error appeared in editor
    * Quit editor
    * Bring up connection "qe-open"
    Then "ether f0:de:aa:fb:bb:cc" is visible with command "ifconfig wlan0"
    Then "qe-open" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_306579
    Scenario: nmcli - wifi - mac adress blacklist
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Note the "ether" property from ifconfig output for device "wlan0"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.mac-address-blacklist" to "noted-value" in editor
    * No error appeared in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    Then "Error" is visible with command "nmcli connection up qe-open"
    Then "\*\s+qe-open" is not visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_306580
    Scenario: nmcli - wifi - set mtu
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Open editor for connection "qe-open"
    * Set a property named "802-11-wireless.mtu" to "64" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-open"
    Then "MTU=64" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-qe-open"
    Then "qe-open" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_306581
    Scenario: nmcli - wifi - seen bssids
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Bring up connection "qe-open"
    * Open editor for connection "qe-open"
    * Note the "802-11-wireless.seen-bssids" property from editor print output
    Then Noted value contains "([0-9A-F]{2}[:-]){5}([0-9A-F]{2})"
    * Quit editor


    @wifi
    @testcase_306582
    Scenario: nmcli - wifi - set and connect to a hidden network
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-hidden-wpa2-psk autoconnect off ssid qe-hidden-wpa2-psk"
    * Check ifcfg-name file created for connection "qe-hidden-wpa2-psk"
    * Open editor for connection "qe-hidden-wpa2-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless.hidden" to "yes" in editor
    * Set a property named "802-11-wireless-security.psk" to "6ubDLTiFr6jDSAxW08GdKU0s5Prh1c5G8CWeYpXHgXeYmhhMyDX8vMMWwLhx8Sl" in editor
    * No error appeared in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-hidden-wpa2-psk"
    Then "qe-hidden-wpa2-psk" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-hidden-wpa2-psk" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_306583
    Scenario: nmcli - wifi - set proper hidden property values
    * Open editor for a type "wifi"
    * Set a property named "802-11-wireless.hidden" to "true" in editor
    * Set a property named "802-11-wireless.hidden" to "yes" in editor
    * Set a property named "802-11-wireless.hidden" to "on" in editor
    * Set a property named "802-11-wireless.hidden" to "false" in editor
    * Set a property named "802-11-wireless.hidden" to "no" in editor
    * Set a property named "802-11-wireless.hidden" to "off" in editor
    Then No error appeared in editor
    * Quit editor


    @wifi
    @testcase_306584
    Scenario: nmcli - wifi - set bogus hidden property values
    * Open editor for a type "wifi"
    * Set a property named "802-11-wireless.hidden" to "0" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.hidden" to "-1" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.hidden" to "valderon" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless.hidden" to "999999999999" in editor
    Then Error appeared in editor
    * Quit editor


    @wifi
    @testcase_306585
    Scenario: nmcli - wifi - 802-11-wireless describe all
    * Open editor for a type "wifi"
    Then Check "ssid|mode|band|channel|bssid|rate|tx-power|mac-address|cloned-mac-address|mac-address-blacklist|mtu|seen-bssids|hidden" are present in describe output for object "802-11-wireless"


    @wifi
    @testcase_306586
    Scenario: nmcli - wifi - describe separately
    * Open editor for a type "wifi"
    Then Check "\[ssid\]" are present in describe output for object "802-11-wireless.ssid"
    Then Check "\[mode\]" are present in describe output for object "802-11-wireless.mode"
    Then Check "\[band\]" are present in describe output for object "802-11-wireless.band"
    Then Check "\[channel\]" are present in describe output for object "802-11-wireless.channel"
    Then Check "\[bssid\]" are present in describe output for object "802-11-wireless.bssid"
    Then Check "\[rate\]" are present in describe output for object "802-11-wireless.rate"
    Then Check "\[tx-power\]" are present in describe output for object "802-11-wireless.tx-power"
    Then Check "\[mac-address\]" are present in describe output for object "802-11-wireless.mac-address"
    Then Check "\[cloned-mac-address\]" are present in describe output for object "802-11-wireless.cloned-mac-address"
    Then Check "\[mac-address-blacklist\]" are present in describe output for object "802-11-wireless.mac-address-blacklist"
    Then Check "\[mtu\]" are present in describe output for object "802-11-wireless.mtu"
    Then Check "\[seen-bssids\]" are present in describe output for object "802-11-wireless.seen-bssids"
    Then Check "\[hidden\]" are present in describe output for object "802-11-wireless.hidden"

    @wifi
    @testcase_309402
    Scenario: nmcli - wifi-sec - 802-11-wireless-security describe all
    * Open editor for a type "wifi"
    Then Check "key-mgmt|wep-tx-keyidx|auth-alg|proto|pairwise|group|leap-username|wep-key0|wep-key1|wep-key2|wep-key3|wep-key-flags|wep-key-type|psk|psk-flags|leap-password|leap-password-flags" are present in describe output for object "802-11-wireless-security"


    @wifi
    @testcase_309403
    Scenario: nmcli - wifi-sec - describe separately
    * Open editor for a type "wifi"
    Then Check "\[key-mgmt\]" are present in describe output for object "802-11-wireless-security.key-mgmt"
    Then Check "\[wep-tx-keyidx\]" are present in describe output for object "802-11-wireless-security.wep-tx-keyidx"
    Then Check "\[auth-alg\]" are present in describe output for object "802-11-wireless-security.auth-alg"
    Then Check "\[proto\]" are present in describe output for object "802-11-wireless-security.proto"
    Then Check "\[pairwise\]" are present in describe output for object "802-11-wireless-security.pairwise"
    Then Check "\[group\]" are present in describe output for object "802-11-wireless-security.group"
    Then Check "\[leap-username\]" are present in describe output for object "802-11-wireless-security.leap-username"
    Then Check "\[wep-key0\]" are present in describe output for object "802-11-wireless-security.wep-key0"
    Then Check "\[wep-key1\]" are present in describe output for object "802-11-wireless-security.wep-key1"
    Then Check "\[wep-key2\]" are present in describe output for object "802-11-wireless-security.wep-key2"
    Then Check "\[wep-key3\]" are present in describe output for object "802-11-wireless-security.wep-key3"
    Then Check "\[wep-key-flags\]" are present in describe output for object "802-11-wireless-security.wep-key-flags"
    Then Check "\[wep-key-type\]" are present in describe output for object "802-11-wireless-security.wep-key-type"
    Then Check "\[psk\]" are present in describe output for object "802-11-wireless-security.psk"
    Then Check "\[psk-flags\]" are present in describe output for object "802-11-wireless-security.psk-flags"
    Then Check "\[leap-password\]" are present in describe output for object "802-11-wireless-security.leap-password"
    Then Check "\[leap-password-flags\]" are present in describe output for object "802-11-wireless-security.leap-password-flags"


    @wifi
    @testcase_309404
    Scenario: nmcli - wifi-sec - configure and connect WPA2-PSK profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa2-psk autoconnect off ssid qe-wpa2-psk"
    * Check ifcfg-name file created for connection "qe-wpa2-psk"
    * Open editor for connection "qe-wpa2-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless-security.psk" to "over the river and through the woods" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wpa2-psk"
    Then "qe-wpa2-psk" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa2-psk" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309405
    Scenario: nmcli - wifi-sec - configure and connect WPA1-PSK profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa1-psk autoconnect off ssid qe-wpa1-psk"
    * Check ifcfg-name file created for connection "qe-wpa1-psk"
    * Open editor for connection "qe-wpa1-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless-security.psk" to "over the river and through the woods" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wpa1-psk"
    Then "qe-wpa1-psk" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa1-psk" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309406
    Scenario: nmcli - wifi-sec - configure and connect WEP hex key profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep autoconnect off ssid qe-wep"
    * Check ifcfg-name file created for connection "qe-wep"
    * Open editor for connection "qe-wep"
    * Set a property named "802-11-wireless-security.key-mgmt" to "none" in editor
    * Set a property named "802-11-wireless-security.wep-key0" to "74657374696E67313233343536" in editor
    * Set a property named "802-11-wireless-security.wep-key-type" to "key" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wep"
    Then "qe-wep" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wep" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309407
    Scenario: nmcli - wifi-sec - configure and connect WEP ascii key profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep autoconnect off ssid qe-wep"
    * Check ifcfg-name file created for connection "qe-wep"
    * Open editor for connection "qe-wep"
    * Set a property named "802-11-wireless-security.key-mgmt" to "none" in editor
    * Set a property named "802-11-wireless-security.wep-key0" to "testing123456" in editor
    * Set a property named "802-11-wireless-security.wep-key-type" to "key" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wep"
    Then "qe-wep" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wep" is visible with command "nmcli -f IN-USE,SSID device wifi list"



    @wifi
    @testcase_309408
    Scenario: nmcli - wifi-sec - configure and connect WEP phrase profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep-psk autoconnect off ssid qe-wep-psk"
    * Check ifcfg-name file created for connection "qe-wep-psk"
    * Open editor for connection "qe-wep-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "none" in editor
    * Set a property named "802-11-wireless-security.wep-key0" to "testing123456" in editor
    * Set a property named "802-11-wireless-security.wep-key-type" to "passphrase" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wep-psk"
    Then "qe-wep-psk" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wep-psk" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309409
    Scenario: nmcli - wifi-sec - configure and connect WPA1-PEAP profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa1-enterprise autoconnect off ssid qe-wpa1-enterprise"
    * Check ifcfg-name file created for connection "qe-wpa1-enterprise"
    * Open editor for connection "qe-wpa1-enterprise"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-eap" in editor
    * Set a property named "802-1x.eap" to "peap" in editor
    * Set a property named "802-1x.identity" to "Bill Smith" in editor
    * Set a property named "802-1x.ca-cert" to "/tmp/certs/eaptest_ca_cert.pem" in editor
    * Set a property named "802-1x.phase2-auth" to "gtc" in editor
    * Set a property named "802-1x.password" to "testing123" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wpa1-enterprise"
    Then "qe-wpa1-enterprise" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa1-enterprise" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309410
    Scenario: nmcli - wifi-sec - configure and connect WPA1-TLS profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa1-enterprise autoconnect off ssid qe-wpa1-enterprise"
    * Check ifcfg-name file created for connection "qe-wpa1-enterprise"
    * Open editor for connection "qe-wpa1-enterprise"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-eap" in editor
    * Set a property named "802-1x.eap" to "tls" in editor
    * Set a property named "802-1x.identity" to "Bill Smith" in editor
    * Set a property named "802-1x.ca-cert" to "/tmp/certs/eaptest_ca_cert.pem" in editor
    * Set a property named "802-1x.client-cert" to "/tmp/certs/client.pem" in editor
    * Set a property named "802-1x.private-key-password" to "12345testing" in editor
    * Set a property named "802-1x.private-key" to "/tmp/certs/client.pem" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wpa1-enterprise"
    Then "qe-wpa1-enterprise" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa1-enterprise" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309411
    Scenario: nmcli - wifi-sec - configure and connect WPA1-TTLS profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa1-enterprise autoconnect off ssid qe-wpa1-enterprise"
    * Check ifcfg-name file created for connection "qe-wpa1-enterprise"
    * Open editor for connection "qe-wpa1-enterprise"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-eap" in editor
    * Set a property named "802-1x.eap" to "ttls" in editor
    * Set a property named "802-1x.phase2-auth" to "mschapv2" in editor
    * Set a property named "802-1x.identity" to "Bill Smith" in editor
    * Set a property named "802-1x.password" to "testing123" in editor
    * Set a property named "802-1x.ca-cert" to "/tmp/certs/eaptest_ca_cert.pem" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wpa1-enterprise"
    Then "qe-wpa1-enterprise" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa1-enterprise" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309412
    Scenario: nmcli - wifi-sec - configure and connect WPA2-PEAP profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa2-enterprise autoconnect off ssid qe-wpa2-enterprise"
    * Check ifcfg-name file created for connection "qe-wpa2-enterprise"
    * Open editor for connection "qe-wpa2-enterprise"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-eap" in editor
    * Set a property named "802-1x.eap" to "peap" in editor
    * Set a property named "802-1x.identity" to "Bill Smith" in editor
    * Set a property named "802-1x.ca-cert" to "/tmp/certs/eaptest_ca_cert.pem" in editor
    * Set a property named "802-1x.phase2-auth" to "gtc" in editor
    * Set a property named "802-1x.password" to "testing123" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wpa2-enterprise"
    Then "qe-wpa2-enterprise" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa2-enterprise" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309413
    Scenario: nmcli - wifi-sec - configure and connect WPA2-TLS profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa2-enterprise autoconnect off ssid qe-wpa2-enterprise"
    * Check ifcfg-name file created for connection "qe-wpa2-enterprise"
    * Open editor for connection "qe-wpa2-enterprise"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-eap" in editor
    * Set a property named "802-1x.eap" to "tls" in editor
    * Set a property named "802-1x.identity" to "Bill Smith" in editor
    * Set a property named "802-1x.ca-cert" to "/tmp/certs/eaptest_ca_cert.pem" in editor
    * Set a property named "802-1x.client-cert" to "/tmp/certs/client.pem" in editor
    * Set a property named "802-1x.private-key-password" to "12345testing" in editor
    * Set a property named "802-1x.private-key" to "/tmp/certs/client.pem" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wpa2-enterprise"
    Then "qe-wpa2-enterprise" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa2-enterprise" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309414
    Scenario: nmcli - wifi-sec - configure and connect WPA2-TTLS profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa2-enterprise autoconnect off ssid qe-wpa2-enterprise"
    * Check ifcfg-name file created for connection "qe-wpa2-enterprise"
    * Open editor for connection "qe-wpa2-enterprise"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-eap" in editor
    * Set a property named "802-1x.eap" to "ttls" in editor
    * Set a property named "802-1x.phase2-auth" to "mschapv2" in editor
    * Set a property named "802-1x.identity" to "Bill Smith" in editor
    * Set a property named "802-1x.password" to "testing123" in editor
    * Set a property named "802-1x.ca-cert" to "/tmp/certs/eaptest_ca_cert.pem" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wpa2-enterprise"
    Then "qe-wpa2-enterprise" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa2-enterprise" is visible with command "nmcli -f IN-USE,SSID device wifi list"

    @wifi
    @testcase_309415
    Scenario: nmcli - wifi-sec - configure and connect WEP LEAP profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep-enterprise-cisco autoconnect off ssid qe-wep-enterprise-cisco"
    * Check ifcfg-name file created for connection "qe-wep-enterprise-cisco"
    * Open editor for connection "qe-wep-enterprise-cisco"
    * Set a property named "802-11-wireless-security.key-mgmt" to "ieee8021x" in editor
    * Set a property named "802-11-wireless-security.auth-alg" to "leap" in editor
    * Set a property named "802-11-wireless-security.leap-username" to "Bill Smith" in editor
    * Set a property named "802-11-wireless-security.leap-password" to "testing123" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wep-enterprise-cisco"
    Then "qe-wep-enterprise-cisco" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wep-enterprise-cisco" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309416
    Scenario: nmcli - wifi-sec - configure and connect WEP-TLS profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep-enterprise autoconnect off ssid qe-wep-enterprise"
    * Check ifcfg-name file created for connection "qe-wep-enterprise"
    * Open editor for connection "qe-wep-enterprise"
    * Set a property named "802-11-wireless-security.key-mgmt" to "ieee8021x" in editor
    * Set a property named "802-1x.eap" to "tls" in editor
    * Set a property named "802-1x.identity" to "Bill Smith" in editor
    * Set a property named "802-1x.ca-cert" to "/tmp/certs/eaptest_ca_cert.pem" in editor
    * Set a property named "802-1x.client-cert" to "/tmp/certs/client.pem" in editor
    * Set a property named "802-1x.private-key-password" to "12345testing" in editor
    * Set a property named "802-1x.private-key" to "/tmp/certs/client.pem" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wep-enterprise"
    Then "qe-wep-enterprise" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wep-enterprise" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309417
    Scenario: nmcli - wifi-sec - configure and connect WEP-TTLS profile
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep-enterprise autoconnect off ssid qe-wep-enterprise"
    * Check ifcfg-name file created for connection "qe-wep-enterprise"
    * Open editor for connection "qe-wep-enterprise"
    * Set a property named "802-11-wireless-security.key-mgmt" to "ieee8021x" in editor
    * Set a property named "802-1x.eap" to "ttls" in editor
    * Set a property named "802-1x.phase2-auth" to "mschapv2" in editor
    * Set a property named "802-1x.identity" to "Bill Smith" in editor
    * Set a property named "802-1x.password" to "testing123" in editor
    * Set a property named "802-1x.ca-cert" to "/tmp/certs/eaptest_ca_cert.pem" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wep-enterprise"
    Then "qe-wep-enterprise" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wep-enterprise" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309418
    Scenario: nmcli - wifi - remove connection while up
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Bring up connection "qe-open"
    * "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    * "qe-open" is visible with command "iw dev wlan0 link"
    * Delete connection "qe-open"
    Then ifcfg-"qe-open" file does not exist
    Then "qe-open" is not visible with command "iw dev wlan0 link"

    @wifi
    @testcase_309419
    Scenario: nmcli - wifi - remove connection while down
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Check ifcfg-name file created for connection "qe-open"
    * Delete connection "qe-open"
    Then ifcfg-"qe-open" file does not exist


    @wifi
    @testcase_309420
    Scenario: nmcli - wifi-sec - key-mgmt - wrong values
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep autoconnect off ssid qe-wep"
    * Check ifcfg-name file created for connection "qe-wep"
    * Open editor for connection "qe-wep"
    * Set a property named "802-11-wireless-security.key-mgmt" to "ieee8021x123" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.key-mgmt" to "ieee8021x sth" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.key-mgmt" to "-1" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.key-mgmt" to "0" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.key-mgmt" to "999999999999999999999" in editor
    Then Error appeared in editor


    @wifi
    @testcase_309421
    Scenario: nmcli - wifi-sec - wep-tx-keyidx - non-default wep key
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep autoconnect off ssid qe-wep"
    * Check ifcfg-name file created for connection "qe-wep"
    * Open editor for connection "qe-wep"
    * Set a property named "802-11-wireless-security.key-mgmt" to "none" in editor
    * Set a property named "802-11-wireless-security.wep-tx-keyidx" to "0" in editor
    * Set a property named "802-11-wireless-security.wep-tx-keyidx" to "1" in editor
    * Set a property named "802-11-wireless-security.wep-tx-keyidx" to "2" in editor
    * Set a property named "802-11-wireless-security.wep-tx-keyidx" to "3" in editor
    * Set a property named "802-11-wireless-security.wep-key3" to "testing123456" in editor
    * Set a property named "802-11-wireless-security.wep-key-type" to "key" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Start tailing file "/var/log/messages"
    * Execute "nmcli connection up qe-wep" without waiting for process to finish
    Then "KEY4=s:testing123456" is visible with command "sudo cat /etc/sysconfig/network-scripts/keys-qe-wep"
    Then Look for "'wep_tx_keyidx' value '3'" in tailed file


    @wifi
    @testcase_309422
    Scenario: nmcli - wifi-sec - wep-tx-keyidx - bogus key id
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep autoconnect off ssid qe-wep"
    * Check ifcfg-name file created for connection "qe-wep"
    * Open editor for connection "qe-wep"
    * Set a property named "802-11-wireless-security.key-mgmt" to "none" in editor
    * No error appeared in editor
    * Set a property named "802-11-wireless-security.wep-tx-keyidx" to "-1" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.wep-tx-keyidx" to "4" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.wep-tx-keyidx" to "999999999999999999999999" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.wep-tx-keyidx" to "walderon" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.wep-tx-keyidx" to "2 0" in editor
    Then Error appeared in editor


    @wifi
    @testcase_309423
    Scenario: nmcli - wifi-sec - auth-alg - wep open key
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep autoconnect off ssid qe-wep"
    * Check ifcfg-name file created for connection "qe-wep"
    * Open editor for connection "qe-wep"
    * Set a property named "802-11-wireless-security.key-mgmt" to "none" in editor
    * Set a property named "802-11-wireless-security.auth-alg" to "open" in editor
    * Set a property named "802-11-wireless-security.wep-key0" to "74657374696E67313233343536" in editor
    * Set a property named "802-11-wireless-security.wep-key-type" to "key" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wep"
    Then "qe-wep" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wep" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309424
    Scenario: nmcli - wifi-sec - auth-alg - wep shared key
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep autoconnect off ssid qe-wep"
    * Check ifcfg-name file created for connection "qe-wep"
    * Open editor for connection "qe-wep"
    * Set a property named "802-11-wireless-security.key-mgmt" to "none" in editor
    * Set a property named "802-11-wireless-security.auth-alg" to "shared" in editor
    * Set a property named "802-11-wireless-security.wep-key0" to "testing123456" in editor
    * Set a property named "802-11-wireless-security.wep-key-type" to "key" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Start tailing file "/var/log/messages"
    * Execute "nmcli connection up qe-wep" without waiting for process to finish
    Then Look for "added 'auth_alg' value 'SHARED'" in tailed file


    @wifi
    @testcase_309425
    Scenario: nmcli - wifi-sec - auth-alg - bogus values and leap with wrong key-mgmt
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep autoconnect off ssid qe-wep"
    * Check ifcfg-name file created for connection "qe-wep"
    * Open editor for connection "qe-wep"
    * Set a property named "802-11-wireless-security.key-mgmt" to "none" in editor
    * No error appeared in editor
    * Set a property named "802-11-wireless-security.auth-alg" to "0" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.auth-alg" to "null" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.auth-alg" to "999999999999999999" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.auth-alg" to "open shared" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.auth-alg" to "leap" in editor
    * No error appeared in editor
    * Save in editor
    Then Error appeared in editor


    @wifi
    @testcase_309426
    Scenario: nmcli - wifi-sec - proto - rsn
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa2-psk autoconnect off ssid qe-wpa2-psk"
    * Check ifcfg-name file created for connection "qe-wpa2-psk"
    * Open editor for connection "qe-wpa2-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless-security.psk" to "over the river and through the woods" in editor
    * Set a property named "802-11-wireless-security.proto" to "rsn" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wpa2-psk"
    Then "qe-wpa2-psk" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa2-psk" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309427
    Scenario: nmcli - wifi-sec - proto - wpa
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa1-psk autoconnect off ssid qe-wpa1-psk"
    * Check ifcfg-name file created for connection "qe-wpa1-psk"
    * Open editor for connection "qe-wpa1-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless-security.psk" to "over the river and through the woods" in editor
    * Set a property named "802-11-wireless-security.proto" to "wpa" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "qe-wpa1-psk"
    Then "qe-wpa1-psk" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa1-psk" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309428
    Scenario: nmcli - wifi-sec - unmatching proto
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa2-psk autoconnect off ssid qe-wpa2-psk"
    * Check ifcfg-name file created for connection "qe-wpa2-psk"
    * Open editor for connection "qe-wpa2-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless-security.psk" to "over the river and through the woods" in editor
    * Set a property named "802-11-wireless-security.proto" to "wpa" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Start tailing file "/var/log/messages"
    Then "Error" is visible with command "nmcli connection up qe-wpa2-psk"
    Then Look for "added 'proto' value 'WPA'" in tailed file
    Then "\*\s+qe-wpa2-psk" is not visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309429
    Scenario: nmcli - wifi-sec - pairwise - ccmp
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa2-psk autoconnect off ssid qe-wpa2-psk"
    * Check ifcfg-name file created for connection "qe-wpa2-psk"
    * Open editor for connection "qe-wpa2-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless-security.psk" to "over the river and through the woods" in editor
    * Set a property named "802-11-wireless-security.pairwise" to "ccmp" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Start tailing file "/var/log/messages"
    * Bring up connection "qe-wpa2-psk"
    Then Look for "added 'pairwise' value 'CCMP'" in tailed file
    Then "qe-wpa2-psk" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa2-psk" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309430
    Scenario: nmcli - wifi-sec - pairwise - tkip
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa1-psk autoconnect off ssid qe-wpa1-psk"
    * Check ifcfg-name file created for connection "qe-wpa1-psk"
    * Open editor for connection "qe-wpa1-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless-security.psk" to "over the river and through the woods" in editor
    * Set a property named "802-11-wireless-security.pairwise" to "tkip" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Start tailing file "/var/log/messages"
    * Bring up connection "qe-wpa1-psk"
    Then Look for "added 'pairwise' value 'TKIP'" in tailed file
    Then "qe-wpa1-psk" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa1-psk" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309431
    Scenario: nmcli - wifi-sec - unmatching pairwise
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa2-psk autoconnect off ssid qe-wpa2-psk"
    * Check ifcfg-name file created for connection "qe-wpa2-psk"
    * Open editor for connection "qe-wpa2-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless-security.psk" to "over the river and through the woods" in editor
    * Set a property named "802-11-wireless-security.pairwise" to "tkip" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Start tailing file "/var/log/messages"
    Then "Error" is visible with command "nmcli connection up qe-wpa2-psk"
    Then Look for "added 'pairwise' value 'TKIP'" in tailed file
    Then "\*\s+qe-wpa2-psk" is not visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309432
    Scenario: nmcli - wifi-sec - group - ccmp
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa2-psk autoconnect off ssid qe-wpa2-psk"
    * Check ifcfg-name file created for connection "qe-wpa2-psk"
    * Open editor for connection "qe-wpa2-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless-security.psk" to "over the river and through the woods" in editor
    * Set a property named "802-11-wireless-security.group" to "ccmp" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Start tailing file "/var/log/messages"
    * Bring up connection "qe-wpa2-psk"
    Then Look for "added 'group' value 'CCMP'" in tailed file
    Then "qe-wpa2-psk" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa2-psk" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309433
    Scenario: nmcli - wifi-sec - group - tkip
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa1-psk autoconnect off ssid qe-wpa1-psk"
    * Check ifcfg-name file created for connection "qe-wpa1-psk"
    * Open editor for connection "qe-wpa1-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless-security.psk" to "over the river and through the woods" in editor
    * Set a property named "802-11-wireless-security.group" to "tkip" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Start tailing file "/var/log/messages"
    * Bring up connection "qe-wpa1-psk"
    Then Look for "added 'group' value 'TKIP'" in tailed file
    Then "qe-wpa1-psk" is visible with command "iw dev wlan0 link"
    Then "\*\s+qe-wpa1-psk" is visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309434
    Scenario: nmcli - wifi-sec - unmatching group
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa2-psk autoconnect off ssid qe-wpa2-psk"
    * Check ifcfg-name file created for connection "qe-wpa2-psk"
    * Open editor for connection "qe-wpa2-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless-security.psk" to "over the river and through the woods" in editor
    * Set a property named "802-11-wireless-security.group" to "tkip" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    * Start tailing file "/var/log/messages"
    Then "Error" is visible with command "nmcli connection up qe-wpa2-psk"
    Then Look for "added 'group' value 'TKIP'" in tailed file
    Then "\*\s+qe-wpa2-psk" is not visible with command "nmcli -f IN-USE,SSID device wifi list"


    @wifi
    @testcase_309435
    Scenario: nmcli - wifi-sec - set all wep keys
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep autoconnect off ssid qe-wep"
    * Check ifcfg-name file created for connection "qe-wep"
    * Open editor for connection "qe-wep"
    * Set a property named "802-11-wireless-security.key-mgmt" to "none" in editor
    * Set a property named "802-11-wireless-security.wep-key0" to "testing123456" in editor
    * Set a property named "802-11-wireless-security.wep-key1" to "testi" in editor
    * Set a property named "802-11-wireless-security.wep-key2" to "123456testing" in editor
    * Set a property named "802-11-wireless-security.wep-key3" to "54321" in editor
    * Set a property named "802-11-wireless-security.wep-key-type" to "key" in editor
    * Save in editor
    * No error appeared in editor
    * Check value saved message showed in editor
    * Quit editor
    Then "KEY1=s:testing123456.+KEY2=s:testi.+KEY3=s:123456testing.+KEY4=s:54321" is visible with command "sudo cat /etc/sysconfig/network-scripts/keys-qe-wep"


    @wifi
    @testcase_309436
    Scenario: nmcli - wifi-sec - wep-key-type auto-detection - passphrase
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wep autoconnect off ssid qe-wep"
    * Check ifcfg-name file created for connection "qe-wep"
    * Open editor for connection "qe-wep"
    * Set a property named "802-11-wireless-security.key-mgmt" to "none" in editor
    * Set a property named "802-11-wireless-security.wep-key0" to "123" in editor
    * "104/128-bit passphrase" appeared in editor
    * Set a property named "802-11-wireless-security.wep-key0" to "aaaaabbsbb" in editor
    * "104/128-bit passphrase" appeared in editor
    * Set a property named "802-11-wireless-security.wep-key0" to "1234A678B01F" in editor
    * "104/128-bit passphrase" appeared in editor
    * Set a property named "802-11-wireless-security.wep-key0" to "1234567890123456" in editor
    * "104/128-bit passphrase" appeared in editor
    * Set a property named "802-11-wireless-security.wep-key0" to "G234567F9012345678911F3451" in editor
    Then "104/128-bit passphrase" appeared in editor


    @wifi
    @testcase_309437
    Scenario: nmcli - wifi-sec - psk validity
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-wpa2-psk autoconnect off ssid qe-wpa2-psk"
    * Check ifcfg-name file created for connection "qe-wpa2-psk"
    * Open editor for connection "qe-wpa2-psk"
    * Set a property named "802-11-wireless-security.key-mgmt" to "wpa-psk" in editor
    * Set a property named "802-11-wireless-security.psk" to "valid size and input for ascii psk @#$%^&*()[]{}" in editor
    * No error appeared in editor
    * Set a property named "802-11-wireless-security.psk" to "short12" in editor
    * Error appeared in editor
    * Set a property named "802-11-wireless-security.psk" to "valid123" in editor
    * No error appeared in editor
    * Set a property named "802-11-wireless-security.psk" to "maximumasciiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii" in editor
    * No error appeared in editor
    * Set a property named "802-11-wireless-security.psk" to "1234A678B01F1234A678B01F1234A678B01F1234A678B01F1234A678B01F123B" in editor
    * No error appeared in editor
    * Set a property named "802-11-wireless-security.psk" to "G234A678B01F1234A678B01F1234A678B01F1234A678B01F1234A678B01F123B" in editor
    * Error appeared in editor


    @wifi
    @testcase_309438
    Scenario: nmcli - wifi - add default connection in novice (nmcli -a) mode
    * Open interactive connection addition mode for a type "wifi"
    * Expect "Interface name"
    * Submit "wlan0"
    * Expect "SSID"
    * Submit "qe-open"
    * Expect "There are 3 optional arguments for 'Wi-Fi' connection type"
    * Submit "no"
    * Expect "Do you want to add IP addresses?"
    * Submit "no"
    * Wait for at least "5" seconds
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    Then "qe-open" is visible with command "iw dev wlan0 link"


    @wifi
    @testcase_309439
    Scenario: nmcli - wifi - add connection in novice (nmcli -a) mode specifying options
    * Open interactive connection addition mode for a type "wifi"
    * Note the "ether" property from ifconfig output for device "wlan0"
    * Expect "Interface name"
    * Submit "wlan0"
    * Expect "SSID"
    * Submit "qe-open"
    * Expect "There are 3 optional arguments for 'Wi-Fi' connection type"
    * Submit "yes"
    * Expect "MTU"
    * Submit "64"
    * Expect "MAC"
    * Submit "noted-value"
    * Expect "Cloned MAC"
    * Submit "noted-value"
    * Expect "Do you want to add IP addresses?"
    * Submit "no"
    * Wait for at least "5" seconds
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    Then "qe-open" is visible with command "iw dev wlan0 link"


    @wifi
    @testcase_309440
    Scenario: nmcli - wifi - add connection in novice (nmcli -a) mode specifying IP setup
    * Open interactive connection addition mode
    * Expect "Connection type"
    * Submit "wifi"
    * Expect "Interface name"
    * Submit "wlan0"
    * Expect "SSID"
    * Submit "qe-open"
    * Expect "There are 3 optional arguments for 'Wi-Fi' connection type"
    * Submit "no"
    * Expect "Do you want to add IP addresses?"
    * Submit "yes"
    * Expect "IPv4 address"
    * Submit "10.1.1.5"
    * No error appeared in editor
    * Submit "10.1.1.6/24"
    * No error appeared in editor
    * Submit "10.1.1.6/24 10.1.1.1"
    * No error appeared in editor
    * Submit "10.1.1.6 10.1.1.1"
    * No error appeared in editor
    * Submit "<enter>"
    * Expect "IPv6 address"
    * Submit "fe80::215:ff:fe93:ffff"
    * No error appeared in editor
    * Submit "fe80::215:ff:fe93:ffff/128"
    * No error appeared in editor
    * Submit "fe80::215:ff:fe93:ffff/128 ::1"
    * No error appeared in editor
    * Submit "fe80::215:ff:fe93:ffff ::1"
    * No error appeared in editor
    * Submit "<enter>"
    * Wait for at least "5" seconds
    Then "\*\s+qe-open" is visible with command "nmcli -f IN-USE,SSID device wifi list"
    Then "qe-open" is visible with command "iw dev wlan0 link"
    Then "10.1.1.5.*fe80::215:ff:fe93:ffff" is visible with command "ip a"
    Then "10.1.1.6" is visible with command "ip a"


    @wifi
    @testcase_309441
    Scenario: nmcli - wifi - add connection in novice (nmcli -a) mode with bogus IP
    * Open interactive connection addition mode
    * Expect "Connection type"
    * Submit "wifi"
    * Expect "Interface name"
    * Submit "wlan0"
    * Expect "SSID"
    * Submit "qe-open"
    * Expect "There are 3 optional arguments for 'Wi-Fi' connection type"
    * Submit "no"
    * Expect "Do you want to add IP addresses?"
    * Submit "yes"
    * Expect "IPv4 address"
    * Submit "280.1.1.5"
    * Error appeared in editor
    * Submit "val.der.oni.uma"
    * Error appeared in editor
    * Submit "-1.1.-1.5"
    * Error appeared in editor
    * Submit "<enter>"
    * Expect "IPv6 address"
    * Submit "feG0::215:ff:fe93:ffff"
    * Error appeared in editor
    * Submit "vald::ron:bogu:sva:vald"
    Then Error appeared in editor


    @wifi
    @testcase_309442
    Scenario: nmcli - wifi - disable radio
    Given  "enabled" is visible with command "nmcli radio wifi"
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect off ssid qe-open"
    * Bring up connection "qe-open"
    * "qe-open" is visible with command "iw dev wlan0 link"
    * Execute "nmcli radio wifi off"
    Then "disabled" is visible with command "nmcli radio wifi"
    Then "qe-open" is not visible with command "iw dev wlan0 link"
    Then "wlan0\s+wifi\s+unavailable" is visible with command "nmcli device"
    * Execute "nmcli radio wifi on"


    @wifi
    @testcase_309443
    Scenario: nmcli - wifi - enable radio
    * Add a new connection of type "wifi" and options "ifname wlan0 con-name qe-open autoconnect on ssid qe-open"
    * Execute "nmcli radio wifi off"
    * "disabled" is visible with command "nmcli radio wifi"
    * "qe-open" is not visible with command "iw dev wlan0 link"
    * "wlan0\s+wifi\s+unavailable" is visible with command "nmcli device"
    * Execute "nmcli radio wifi on"
    Then "enabled" is visible with command "nmcli radio wifi"
    Then "qe-open" is visible with command "iw dev wlan0 link"
    Then "wlan0\s+wifi\s+connected" is visible with command "nmcli device"
