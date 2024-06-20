start_addr = 0x`objdump -dC install/lib/librclcpp.so | grep "<rclcpp::experimental::TimersManager::enqueue_ready_timers_unsafe()>" | awk '{print $1}'`
end_addr = 0x`objdump -dC install/lib/librclcpp.so | grep "<rclcpp::experimental::TimersManager::get_head_timeout_unsafe()>" | awk '{print $1}'`

echo "p:timer_manager_loop_enter $(pwd)/install/lib/librclcpp.so:$start_addr" > /sys/kernel/debug/tracing/uprobe_events
echo "r:timer_manager_loop_exit $(pwd)/install/lib/librclcpp.so:$end_addr" > /sys/kernel/debug/tracing/uprobe_events

trace-cmd record -e timer_manager_loop_enter,timer_manager_loop_exit -o timers_only_benchmark_uniprocessor.dat ./install/lib/rtss_evaluation/timers_only 120 edf ro

# TODO: trace-cmd report and get time deltas of entry and exit points