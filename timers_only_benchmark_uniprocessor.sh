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

ros2 trace start trace-timers-only.rm.ro.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration rm ro | tee trace-timers-only.rm.ro.uu.log
ros2 trace stop trace-timers-only.rm.ro.uu

ros2 trace start trace-timers-only.rm.re.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration rm re | tee trace-timers-only.rm.re.uu.log
ros2 trace stop trace-timers-only.rm.re.uu

ros2 trace start trace-timers-only.edf.ro.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration edf ro | tee trace-timers-only.edf.ro.uu.log
ros2 trace stop trace-timers-only.edf.ro.uu

ros2 trace start trace-timers-only.edf.re.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration edf re | tee trace-timers-only.edf.re.uu.log
ros2 trace stop trace-timers-only.edf.re.uu

ros2 trace start trace-timers-only.events.ro.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration events ro | tee trace-timers-only.events.ro.uu.log
ros2 trace stop trace-timers-only.events.ro.uu

ros2 trace start trace-timers-only.events.re.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration events re | tee trace-timers-only.events.re.uu.log
ros2 trace stop trace-timers-only.events.re.uu

ros2 trace start trace-timers-only.default.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration default | tee trace-timers-only.default.uu.log
ros2 trace stop trace-timers-only.default.uu

ros2 trace start trace-timers-only.rm.ro.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration rm ro | tee trace-timers-only.rm.ro.hu.log
ros2 trace stop trace-timers-only.rm.ro.hu

ros2 trace start trace-timers-only.rm.re.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration rm re | tee trace-timers-only.rm.re.hu.log
ros2 trace stop trace-timers-only.rm.re.hu

ros2 trace start trace-timers-only.edf.ro.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration edf ro | tee trace-timers-only.edf.ro.hu.log
ros2 trace stop trace-timers-only.edf.ro.hu

ros2 trace start trace-timers-only.edf.re.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration edf re | tee trace-timers-only.edf.re.hu.log
ros2 trace stop trace-timers-only.edf.re.hu

ros2 trace start trace-timers-only.events.ro.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration events ro | tee trace-timers-only.events.ro.hu.log
ros2 trace stop trace-timers-only.events.ro.hu

ros2 trace start trace-timers-only.events.re.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration events re | tee trace-timers-only.events.re.hu.log
ros2 trace stop trace-timers-only.events.re.hu

ros2 trace start trace-timers-only.default.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration default | tee trace-timers-only.default.hu.log
ros2 trace stop trace-timers-only.default.hu

ros2 trace start trace-timers-only.rm.ro.ou
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration rm ro | tee trace-timers-only.rm.ro.ou.log
ros2 trace stop trace-timers-only.rm.ro.ou

ros2 trace start trace-timers-only.rm.re.ou
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration rm re | tee trace-timers-only.rm.re.ou.log
ros2 trace stop trace-timers-only.rm.re.ou

ros2 trace start trace-timers-only.edf.ro.ou
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration edf ro | tee trace-timers-only.edf.ro.ou.log
ros2 trace stop trace-timers-only.edf.ro.ou

ros2 trace start trace-timers-only.edf.re.ou
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration edf re | tee trace-timers-only.edf.re.ou.log
ros2 trace stop trace-timers-only.edf.re.ou

ros2 trace start trace-timers-only.events.ro.ou
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration events ro | tee trace-timers-only.events.ro.ou.log
ros2 trace stop trace-timers-only.events.ro.ou

ros2 trace start trace-timers-only.events.re.ou
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration events re | tee trace-timers-only.events.re.ou.log
ros2 trace stop trace-timers-only.events.re.ou

ros2 trace start trace-timers-only.default.ou
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration default | tee trace-timers-only.default.ou.log
ros2 trace stop trace-timers-only.default.ou

cp -r ~/.ros/tracing/trace-timers-only.* .
chown -R $SUDO_USER:$SUDO_USER trace-timers-only.*
