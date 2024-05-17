#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Script needs root, please run: "
   echo "sudo env PATH=\"\$PATH\" LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH\" !! "
   # sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./sequences_benchmark.sh
   exit 1
fi

duration=5

rm -r ~/.ros/tracing/sequences-*
source install/setup.bash


ros2 trace start sequences-rm-ro
./install/lib/rtss_evaluation/sequences $duration rm ro | tee sequences-rm-ro.log
ros2 trace stop sequences-rm-ro

ros2 trace start sequences-rm-re
./install/lib/rtss_evaluation/sequences $duration rm re | tee sequences-rm-re.log
ros2 trace stop sequences-rm-re

ros2 trace start sequences-events-ro
./install/lib/rtss_evaluation/sequences $duration events ro | tee sequences-events-ro.log
ros2 trace stop sequences-events-ro

ros2 trace start sequences-events-re
./install/lib/rtss_evaluation/sequences $duration events re | tee sequences-events-re.log
ros2 trace stop sequences-events-re

ros2 trace start sequences-default
./install/lib/rtss_evaluation/sequences $duration default | tee sequences-default.log
ros2 trace stop sequences-default

cp -r ~/.ros/tracing/sequences-* .
chown -R $SUDO_USER:$SUDO_USER sequences-*
