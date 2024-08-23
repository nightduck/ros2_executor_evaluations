#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Script needs root, please run: "
   echo "sudo env PATH=\"\$PATH\" LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH\" !! "
   # sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./timers_only_benchmark.sh
   exit 1
fi

duration=5

rm -r ~/.ros/tracing/trace-timers-only.*
source /opt/ros/rolling/setup.bash
source install/setup.bash

ros2 trace start -k sched_switch -l trace-timers-only.rm.uu
./install/lib/rtss_evaluation/timers_only $duration rm | tee trace-timers-only.rm.uu.log
ros2 trace stop trace-timers-only.rm.uu

ros2 trace start -k sched_switch -l trace-timers-only.edf.uu
./install/lib/rtss_evaluation/timers_only $duration edf | tee trace-timers-only.edf.uu.log
ros2 trace stop trace-timers-only.edf.uu

ros2 trace start -k sched_switch -l trace-timers-only.events.uu
./install/lib/rtss_evaluation/timers_only $duration events | tee trace-timers-only.events.uu.log
ros2 trace stop trace-timers-only.events.uu

ros2 trace start -k sched_switch -l trace-timers-only.default
./install/lib/rtss_evaluation/timers_only $duration | tee trace-timers-only.default.log
ros2 trace stop trace-timers-only.default

ros2 trace start -k sched_switch -l trace-timers-only.rm.uu
./install/lib/rtss_evaluation/timers_only_high_utilization $duration rm | tee trace-timers-only.rm.uu.log
ros2 trace stop trace-timers-only.rm.uu

ros2 trace start -k sched_switch -l trace-timers-only.edf.uu
./install/lib/rtss_evaluation/timers_only_high_utilization $duration edf | tee trace-timers-only.edf.uu.log
ros2 trace stop trace-timers-only.edf.uu

ros2 trace start -k sched_switch -l trace-timers-only.events.uu
./install/lib/rtss_evaluation/timers_only_high_utilization $duration events | tee trace-timers-only.events.uu.log
ros2 trace stop trace-timers-only.events.uu

ros2 trace start -k sched_switch -l trace-timers-only.default
./install/lib/rtss_evaluation/timers_only_high_utilization $duration | tee trace-timers-only.default.log
ros2 trace stop trace-timers-only.default

ros2 trace start -k sched_switch -l trace-timers-only.rm.uu
./install/lib/rtss_evaluation/timers_only_over_utilization $duration rm | tee trace-timers-only.rm.uu.log
ros2 trace stop trace-timers-only.rm.uu

ros2 trace start -k sched_switch -l trace-timers-only.edf.uu
./install/lib/rtss_evaluation/timers_only_over_utilization $duration edf | tee trace-timers-only.edf.uu.log
ros2 trace stop trace-timers-only.edf.uu

ros2 trace start -k sched_switch -l trace-timers-only.events.uu
./install/lib/rtss_evaluation/timers_only_over_utilization $duration events | tee trace-timers-only.events.uu.log
ros2 trace stop trace-timers-only.events.uu

ros2 trace start -k sched_switch -l trace-timers-only.default
./install/lib/rtss_evaluation/timers_only_over_utilization $duration | tee trace-timers-only.default.log
ros2 trace stop trace-timers-only.default

cp -r ~/.ros/tracing/trace-timers-only.* .
chown -R $SUDO_USER:$SUDO_USER trace-timers-only.*
