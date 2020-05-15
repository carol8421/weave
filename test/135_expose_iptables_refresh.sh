#!/bin/bash

. "$(dirname "$0")/config.sh"

echo_rules() {
    local rules=$(get_command_output_on $HOST1 "sudo iptables-save | grep -i weave")
    echo $rules
}

wait_for_iptable_refresh() {
    sleep 2
}

start_suite "exposing weave network to host"

weave_on $HOST1 launch --iptables-refresh-interval=0s

# Check no refreshing
IPT_BEFORE=$(mktemp)
IPT_AFTER=$(mktemp)
run_on $HOST1 "sudo iptables-save | grep -i weave > $IPT_BEFORE"
run_on $HOST1 sudo iptables -t nat -D POSTROUTING -j WEAVE
wait_for_iptable_refresh
run_on $HOST1 "sudo iptables-save | grep -i weave > $IPT_AFTER"
assert_raises "run_on $HOST1 diff $IPT_BEFORE $IPT_AFTER" 1

weave_on $HOST1 stop
weave_on $HOST1 launch --iptables-refresh-interval=1s

# Check refreshing
IPT_BEFORE=$(mktemp)
IPT_AFTER=$(mktemp)
run_on $HOST1 "sudo iptables-save | grep -i weave > $IPT_BEFORE"
run_on $HOST1 sudo iptables -t nat -D POSTROUTING -j WEAVE
wait_for_iptable_refresh
run_on $HOST1 "sudo iptables-save | grep -i weave > $IPT_AFTER"
assert_raises "run_on $HOST1 diff $IPT_BEFORE $IPT_AFTER"

end_suite
