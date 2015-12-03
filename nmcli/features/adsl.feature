Feature: nmcli: adsl

    @rhbz1264089
    @adsl
    @add_adsl_connection_novice_mode
    Scenario: nmcli - adsl - create adsl connection in novice mode
    * Open wizard for adding new connection
    * Expect "Connection type"
    * Submit "adsl" in editor
    * Expect "Interface name"
    * Submit "test11" in editor
    * Expect "Username"
    * Submit "test" in editor
    * Expect "Protocol"
    * Submit "pppoe" in editor
    * Expect "There are 2 optional arguments"
    * Enter in editor
    * Expect "Password"
    * Submit "redhat" in editor
    * Expect "ADSL encapsulation"
    * Enter in editor
    * Expect "Do you want to add IP addresses\? \(yes\/no\) \[yes\]"
    * Submit "no" in editor
    Then "adsl.username:\s+test" is visible with command "nmcli  connection show --show-secrets adsl-test11"
    Then "adsl.password:\s+redhat" is visible with command "nmcli  connection show --show-secrets adsl-test11"
    Then "adsl.protocol:\s+pppoe" is visible with command "nmcli  connection show --show-secrets adsl-test11"
    Then "adsl.encapsulation:\s+--" is visible with command "nmcli  connection show --show-secrets adsl-test11"


    @rhbz1264089
    @adsl
    @add_adsl_connection
    Scenario: nmcli - adsl - create adsl connection
    * Execute "nmcli connection add type adsl ifname adsl con-name adsl-test11 username test password redhat protocol pppoe encapsulation llc"
    Then "adsl.username:\s+test" is visible with command "nmcli  connection show --show-secrets adsl-test11"
    Then "adsl.password:\s+redhat" is visible with command "nmcli  connection show --show-secrets adsl-test11"
    Then "adsl.protocol:\s+pppoe" is visible with command "nmcli  connection show --show-secrets adsl-test11"
    Then "adsl.encapsulation:\s+llc" is visible with command "nmcli  connection show --show-secrets adsl-test11"
