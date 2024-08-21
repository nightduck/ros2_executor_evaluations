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


ros2 trace start trace-sequences.rm.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences $duration rm | tee trace-sequences.rm.ro.uu.log
ros2 trace stop trace-sequences.rm.uu

ros2 trace start trace-sequences.events.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences $duration events | tee trace-sequences.events.ro.uu.log
ros2 trace stop trace-sequences.events.uu

ros2 trace start trace-sequences.default.uu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences $duration default | tee trace-sequences.default.uu.log
ros2 trace stop trace-sequences.default.uu

ros2 trace start trace-sequences.rm.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences_high_utilization $duration rm | tee trace-sequences.rm.ro.hu.log
ros2 trace stop trace-sequences.rm.hu

ros2 trace start trace-sequences.events.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences_high_utilization $duration events | tee trace-sequences.events.ro.hu.log
ros2 trace stop trace-sequences.events.hu

ros2 trace start trace-sequences.default.hu
chrt -f 50 taskset 0x8 ./install/lib/rtss_evaluation/sequences_high_utilization $duration default | tee trace-sequences.default.hu.log
ros2 trace stop trace-sequences.default.hu

cp -r ~/.ros/tracing/trace-sequences.* .
chown -R $SUDO_USER:$SUDO_USER trace-sequences.*
