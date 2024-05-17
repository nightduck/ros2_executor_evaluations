#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Script needs root, please run: "
   echo "sudo env PATH=\"\$PATH\" LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH\" !! "
   # sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./timers_only_benchmark.sh
   exit 1
fi

duration=5

rm -r ~/.ros/tracing/timers-only-*
source install/setup.bash


ros2 trace start -k sched_switch -l timers-only-rm-ro
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration rm ro | tee timers-only-rm-ro.log
ros2 trace stop timers-only-rm-ro

ros2 trace start -k sched_switch -l timers-only-rm-re
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration rm re | tee timers-only-rm-re.log
ros2 trace stop timers-only-rm-re

ros2 trace start -k sched_switch -l timers-only-edf-ro
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration edf ro | tee timers-only-edf-ro.log
ros2 trace stop timers-only-edf-ro

ros2 trace start -k sched_switch -l timers-only-edf-re
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration edf re | tee timers-only-edf-re.log
ros2 trace stop timers-only-edf-re

ros2 trace start -k sched_switch -l timers-only-events-ro
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration events ro | tee timers-only-events-ro.log
ros2 trace stop timers-only-events-ro

ros2 trace start -k sched_switch -l timers-only-events-re
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration events re | tee timers-only-events-re.log
ros2 trace stop timers-only-events-re

ros2 trace start -k sched_switch -l timers-only-default
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration default | tee timers-only-default.log
ros2 trace stop timers-only-default

cp -r ~/.ros/tracing/timers-only-* .
chown -R $SUDO_USER:$SUDO_USER timers-only-*
