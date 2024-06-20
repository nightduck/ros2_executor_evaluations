#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Script needs root, please run: "
   echo "sudo env PATH=\"\$PATH\" LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH\" !! "
   # sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./sequences_benchmark_uniprocessor.sh
   exit 1
fi

duration=5

UU=60
HU=80
OU=90

rm -r ~/.ros/tracing/trace-sequences.*
source install/setup.bash


ros2 trace start trace-sequences.rm.ro.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences $duration rm ro | tee trace-sequences.rm.ro.uu.log
ros2 trace stop trace-sequences.rm.ro.uu

ros2 trace start trace-sequences.rm.re.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences $duration rm re | tee trace-sequences.rm.re.uu.log
ros2 trace stop trace-sequences.rm.re.uu

ros2 trace start trace-sequences.events.ro.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences $duration events ro | tee trace-sequences.events.ro.uu.log
ros2 trace stop trace-sequences.events.ro.uu

ros2 trace start trace-sequences.events.re.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences $duration events re | tee trace-sequences.events.re.uu.log
ros2 trace stop trace-sequences.events.re.uu

ros2 trace start trace-sequences.default.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences $duration default | tee trace-sequences.default.uu.log
ros2 trace stop trace-sequences.default.uu

ros2 trace start trace-sequences.rm.ro.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences_high_utilization $duration rm ro | tee trace-sequences.rm.ro.hu.log
ros2 trace stop trace-sequences.rm.ro.hu

ros2 trace start trace-sequences.rm.re.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences_high_utilization $duration rm re | tee trace-sequences.rm.re.hu.log
ros2 trace stop trace-sequences.rm.re.hu

ros2 trace start trace-sequences.events.ro.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences_high_utilization $duration events ro | tee trace-sequences.events.ro.hu.log
ros2 trace stop trace-sequences.events.ro.hu

ros2 trace start trace-sequences.events.re.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences_high_utilization $duration events re | tee trace-sequences.events.re.hu.log
ros2 trace stop trace-sequences.events.re.hu

ros2 trace start trace-sequences.default.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences_high_utilization $duration default | tee trace-sequences.default.hu.log
ros2 trace stop trace-sequences.default.hu

cp -r ~/.ros/tracing/trace-sequences.* .
chown -R $SUDO_USER:$SUDO_USER trace-sequences.*
