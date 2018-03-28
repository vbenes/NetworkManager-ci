#! /usr/bin/python

from subprocess import call

skip_long = True
skip_restart = True

tests = ['bond_add_default_bond', 'nmcli_editor_for_new_connection_set_con_id', 'bond_disconnect', 'bond_remove_active_bond_profile', 'bond_add_slaves', 'add_bond_master_via_uuid', 'bond_ifcfg_master_as_device', 'bond_ifcfg_master_called_ethernet', 'bond_ifcfg_master_as_device_via_con_name', 'nmcli_bond_manual_ipv4', 'bond_remove_slave', 'bond_remove_all_slaves', 'bond_start_by_hand', 'bond_start_by_hand_no_slaves', 'bond_activate', 'bond_start_on_boot', 'bond_default_rhel7_slaves_ordering', 'bond_slaves_ordering_by_ifindex', 'bond_slaves_ordering_by_ifindex_with_autoconnect_slaves', 'bond_slaves_ordering_by_name', 'bond_slaves_ordering_by_name_with_autoconnect_slaves', 'bond_set_miimon_values', 'bond_options_new_arp_values', 'bond_options_arp_vs_miimon_conflict', 'bond_option_mode_missing', 'bond_add_option', 'bond_mode_incorrect_value', 'bond_change_options', 'bond_remove_option', 'bond_overwrite_options', 'bond_mode_balance_rr', 'bond_mode_active_backup', 'bond_active-backup_primary_set', 'bond_mode_balance_xor', 'bond_mode_broadcast', 'bond_slaves_start_via_master', 'bond_start_on_boot_with_nothing_auto', 'bond_mac_spoof', 'bond_mac_reconnect_preserve', 'bond_start_by_hand_with_one_auto_only', 'bond_start_on_boot_with_one_auto_only', 'bond_start_on_boot_with_bond_and_one_slave_auto', 'bond_mode_8023ad', 'bond_8023ad_with_lacp_rate_fast', 'bond_mode_balance_tlb', 'bond_mode_balance_alb', 'bond_set_mtu', 'bond_addreses_restart_persistence', 'bond_describe', 'delete_addrgenmode_bond', 'nmcli_novice_mode_create_bond_with_mii_monitor_values', 'nmcli_novice_mode_create_bond_with_default_options', 'nmcli_novice_mode_create_bond_with_arp_monitor_values', 'nmcli_novice_mode_create_bond-slave_with_default_options', 'bond_reflect_changes_from_outside_of_NM', 'bond_dbus_creation', 'bond_mode_by_number_in_ifcfg', 'bond_set_active_backup_options', 'bond_set_ad_options', 'bond_set_arp_all_targets', 'bond_set_packets_per_slave_option', 'bond_set_balance_tlb_options', 'bond_device_rename', 'bond_enslave_to_bridge', 'bridge_team_bond_autoconnect_nested_slaves', 'bond_in_bridge_mtu', 'bond_8023ad_no_error', 'bond_balance-alb_no_error', 'reapply_unchanged_slave', 'vlan_over_no_L3_bond_restart_persistence', 'bond_leave_L2_only_up_when_going_down', 'bond_assume_options_1', 'bond_assume_options_2', 'bond_assume_options_3', 'nmclient_bond_get_state_flags', 'bridge_add_default', 'bridge_add_custom_one', 'bridge_add_forward_delay', 'bridge_modify_forward_delay', 'bridge_connection_up', 'bridge_connection_down', 'bridge_disconnect_device', 'bridge_describe_all', 'bridge_describe_separately', 'bridge_delete_connection', 'bridge_delete_connection_while_up', 'bridge_add_slave', 'bridge_remove_slave', 'bridge_up_with_slaves', 'bridge_up_slave', 'bridge_slaves_start_via_master', 'bridge_autoconnect_slaves_when_master_reconnected', 'bridge_dhcp_config_with_ethernet_port', 'bridge_dhcp_config_with_multiple_ethernet_ports', 'bridge_static_config_with_multiple_ethernet_ports', 'bridge_server_ingore_carrier_with_dhcp', 'bridge_reflect_changes_from_outside_of_NM', 'bridge_assumed_connection_race', 'bridge_assumed_connection_no_firewalld_zone', 'bridge_manipulation_with_1000_slaves', 'bridge_assumed_connection_ip_methods', 'outer_bridge_restart_persistence', 'bridge_set_mac', 'bridge_set_mac_var1', 'bridge_set_mac_var2', 'bridge_external_unmanaged', 'bridge_preserve_assumed_connection_ips', 'bridge_slave_to_ethernet_conversion', 'bridge_delete_connection_with_device', 'bridge_delete_connection_without_device', 'connection_restricted_to_single_device', 'connection_help', 'device_autocompletion', 'connection_names_autocompletion', 'connection_get_value', 'connection_no_error', 'connection_secondaries_restricted_to_vpn', 'connection_double_delete', 'connection_profile_duplication', 'double_connection_warning', 'connection_veth_profile_duplication', 'connection_delete_while_editing', 'connection_removal_of_disapperared_device', 'connection_down', 'connection_set_id', 'connection_set_uuid_error', 'connection_set_interface-name', 'connection_autoconnect_yes', 'connection_autoconnect_no', 'connection_autoconnect_yes_without_immediate_effects', 'ifcfg_parse_options_with_comment', 'ifcfg_compliant_with_kickstart', 'manual_connection_with_both_ips_consumption', 'stable_mem_consumption2', 'dummy_connection', 'dummy_with_qdisc', 'do_not_touch_external_dummy', 'macsec_psk', 'non_utf_device', 'connectivity_check', 'disable_connectivity_check', 'manipulate_connectivity_check_via_dbus', 'per_device_connectivity_check', 'keep_external_device_enslaved_on_down', 'overtake_external_device', 'wait_10s_for_flappy_carrier', 'nmcli_general_correct_profile_activated_after_restart', 'nmcli_general_profile_pickup_doesnt_break_network', 'ipv4_take_manually_created_ifcfg_with_ip', 'add_default_team', 'add_default_team_after_journal_restart', 'ifcfg_team_slave_device_type', 'nmcli_novice_mode_create_team', 'nmcli_novice_mode_create_team-slave_with_default_options', 'add_two_slaves_to_team', 'default_config_watch', 'add_team_master_via_uuid', 'remove_all_slaves', 'remove_one_slave', 'remove_active_team_profile', 'disconnect_active_team', 'team_start_by_hand_no_slaves', 'team_activate', 'team_slaves_start_via_master', 'team_mac_spoof', 'team_mac_spoof_var1', 'start_team_by_hand_all_auto', 'start_team_by_hand_one_auto', 'start_team_on_boot', 'team_start_on_boot_with_nothing_auto', 'team_start_on_boot_with_one_auto_only', 'team_start_on_boot_with_team_and_one_slave_auto', 'config_loadbalance', 'config_broadcast', 'config_lacp', 'config_invalid3', 'remove_config', 'team_set_mtu', 'team_reflect_changes_from_outside_of_NM', 'kill_teamd', 'team_enslave_to_bridge', 'describe', 'team_in_bridge_mtu', 'team_config_null', 'ifcfg_with_missing_devicetype', 'team_in_vlan', 'team_in_vlan_restart_persistence', 'vlan_in_team', 'team_leave_L2_only_up_when_going_down', 'team_add_into_firewall_zone', 'reconnect_back_to_ethernet_after_master_delete', 'team_abs_set_runners', 'team_abs_set_runner_hwaddr_policy', 'team_abs_set_runner_tx_hash', 'team_abs_set_runner_tx_balancer', 'team_abs_set_runner_tx_balancer_interval', 'team_abs_set_runner_active', 'team_abs_set_runner_fast_rate', 'team_abs_set_runner_sys_prio', 'team_abs_set_runner_min_ports', 'team_abs_set_runner_agg_select_policy', 'team_abs_set_notify_peers', 'team_abs_set_mcast_rejoin', 'team_abs_set_link_watchers_ethtool', 'team_abs_set_link_watchers_nsna_ping', 'team_abs_set_link_watchers_arp_ping', 'team_abs_overwrite_watchers', 'wait_for_slow_teamd']


# def runtest(test):
#     return call ("/mnt/tests/NetworkManager-ci/nmcli/./runtest.sh %s" %test, shell=True)

# set some basic defaults
if skip_long:
    call ("touch /tmp/nm_skip_long", shell=True)
if skip_restart:
    call ("touch /tmp/nm_skip_restarts", shell=True)

call ("echo '********* STARTING TEST THREAD1 *********' >> /tmp/tests", shell=True)

failures = []
for test in tests:
    if call ("cd /mnt/tests/NetworkManager-ci/ && sh nmcli/./runtest.sh %s" %test, shell=True) != 0:
        failures.append(test)
        call ("echo %s >> /tmp/test1.failures" %test, shell=True)
        call ("echo '1: FAIL:%s' >> /tmp/tests" % test, shell=True)
    else:
        call ("echo '1: PASS:%s' >> /tmp/tests" % test, shell=True)
call ("echo '********* ENDING TEST THREAD1 *********' >> /tmp/tests", shell=True)

if failures != []:
    print ("TESTS-FAILED:")
    for fail in failures:
        print (fail)
    exit(1)
else:
    print ("TESTS-PASSED")
    exit(0)
