#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Script needs root, please run: "
   echo "sudo env PATH=\"\$PATH\" LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH\" !! "
   # sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./sequences_benchmark.sh
   exit 1
fi

duration=5

rm -r ~/.ros/tracing/sequences.*
source install/setup.bash


ros2 trace start sequences.rm.ro.uu
chrt -f 50 ./install/lib/rtss_evaluation/sequences $duration rm ro | tee sequences.rm.ro.uu.log
ros2 trace stop sequences.rm.ro.uu

ros2 trace start sequences.rm.re.uu
chrt -f 50 ./install/lib/rtss_evaluation/sequences $duration rm re | tee sequences.rm.re.uu.log
ros2 trace stop sequences.rm.re.uu

ros2 trace start sequences.events.ro.uu
chrt -f 50 ./install/lib/rtss_evaluation/sequences $duration events ro | tee sequences.events.ro.uu.log
ros2 trace stop sequences.events.ro.uu

ros2 trace start sequences.events.re.uu
chrt -f 50 ./install/lib/rtss_evaluation/sequences $duration events re | tee sequences.events.re.uu.log
ros2 trace stop sequences.events.re.uu

ros2 trace start sequences.default.uu
chrt -f 50 ./install/lib/rtss_evaluation/sequences $duration default | tee sequences.default.uu.log
ros2 trace stop sequences.default.uu

ros2 trace start sequences.rm.ro.hu
chrt -f 50 ./install/lib/rtss_evaluation/sequences_high_utilization $duration rm ro | tee sequences.rm.ro.hu.log
ros2 trace stop sequences.rm.ro.hu

ros2 trace start sequences.rm.re.hu
chrt -f 50 ./install/lib/rtss_evaluation/sequences_high_utilization $duration rm re | tee sequences.rm.re.hu.log
ros2 trace stop sequences.rm.re.hu

ros2 trace start sequences.events.ro.hu
chrt -f 50 ./install/lib/rtss_evaluation/sequences_high_utilization $duration events ro | tee sequences.events.ro.hu.log
ros2 trace stop sequences.events.ro.hu

ros2 trace start sequences.events.re.hu
chrt -f 50 ./install/lib/rtss_evaluation/sequences_high_utilization $duration events re | tee sequences.events.re.hu.log
ros2 trace stop sequences.events.re.hu

ros2 trace start sequences.default.hu
chrt -f 50 ./install/lib/rtss_evaluation/sequences_high_utilization $duration default | tee sequences.default.hu.log
ros2 trace stop sequences.default.hu

cp -r ~/.ros/tracing/sequences.* .
chown -R $SUDO_USER:$SUDO_USER sequences.*
