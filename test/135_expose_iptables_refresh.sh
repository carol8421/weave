#!/bin/bash

. "$(dirname "$0")/config.sh"

run_on1() {
    assert_raises "run_on $HOST1 $@"
}

weave_on1() {
    assert_raises "weave_on $HOST1 $@"
}

stop_weave_on1() {
    assert_raises "stop_weave_on $HOST1 $@"
}

echo_rules() {
    local rules=$(get_command_output_on $HOST1 "sudo iptables-save | grep -i weave")
    echo $rules
}

make_temp_file() {
    get_command_output_on $HOST1 "mktemp"
}

wait_for_iptable_refresh() {
    sleep 2
}

start_suite "exposing weave network to host"

# Launch

## Check no refreshing
weave_on1 "launch --iptables-refresh-interval=0s"
IPT_BEFORE=$(mktemp)
IPT_AFTER=$(mktemp)
run_on1 "sudo iptables-save | grep -i weave > $IPT_BEFORE"
echo_rules
run_on1 "sudo iptables -t nat -D POSTROUTING -j WEAVE"
echo_rules
wait_for_iptable_refresh
echo_rules
run_on1 "sudo iptables-save | grep -i weave > $IPT_AFTER"
assert_raises "run_on $HOST1 diff $IPT_BEFORE $IPT_AFTER" 1
get_command_output_on $HOST1 "diff $IPT_BEFORE $IPT_AFTER"
stop_weave_on1

## Check refreshing
weave_on1 "launch --iptables-refresh-interval=1s"
IPT_BEFORE=$(mktemp)
IPT_AFTER=$(mktemp)
run_on1 "sudo iptables-save | grep -i weave > $IPT_BEFORE"
echo_rules
run_on1 "sudo iptables -t nat -D POSTROUTING -j WEAVE"
echo_rules
wait_for_iptable_refresh
echo_rules
run_on1 "sudo iptables-save | grep -i weave > $IPT_AFTER"
assert_raises "run_on $HOST1 diff $IPT_BEFORE $IPT_AFTER"
get_command_output_on $HOST1 "diff $IPT_BEFORE $IPT_AFTER"
stop_weave_on1

# Expose

## Check no refreshing
weave_on1 "launch --iptables-refresh-interval=0s"
weave_on1 "expose"
IPT_BEFORE=$(mktemp)
IPT_AFTER=$(mktemp)
run_on1 "sudo iptables-save | grep -i weave > $IPT_BEFORE"
echo_rules
run_on1 "sudo iptables -D FORWARD -o weave -j WEAVE-EXPOSE"
echo_rules
wait_for_iptable_refresh
echo_rules
run_on1 "sudo iptables-save | grep -i weave > $IPT_AFTER"
assert_raises "run_on $HOST1 diff $IPT_BEFORE $IPT_AFTER" 1
get_command_output_on $HOST1 "diff $IPT_BEFORE $IPT_AFTER"
stop_weave_on1

## Check refreshing
weave_on1 "launch --iptables-refresh-interval=1s"
weave_on1 "expose"
IPT_BEFORE=$(mktemp)
IPT_AFTER=$(mktemp)
run_on1 "sudo iptables-save | grep -i weave > $IPT_BEFORE"
echo_rules
run_on1 "sudo iptables -D FORWARD -o weave -j WEAVE-EXPOSE"
echo_rules
wait_for_iptable_refresh
echo_rules
run_on1 "sudo iptables-save | grep -i weave > $IPT_AFTER"
assert_raises "run_on $HOST1 diff $IPT_BEFORE $IPT_AFTER"
get_command_output_on $HOST1 "diff $IPT_BEFORE $IPT_AFTER"
stop_weave_on1

end_suite
