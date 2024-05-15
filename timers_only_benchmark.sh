#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Script needs root, please run: "
   echo "sudo env PATH=\"\$PATH\" LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH\" !! "
   exit 1
fi

duration=5

rm -r ~/.ros/tracing/timers-only-*
source install/setup.bash

# TODO: ros2 trace start/stop don't actually work and result in empty traces

ros2 trace start timers-only-rm-ro
./install/lib/rtss_evaluation/timers_only $duration rm ro | tee timers-only-rm-ro.log
ros2 trace stop timers-only-rm-ro

ros2 trace start timers-only-rm-re
./install/lib/rtss_evaluation/timers_only $duration rm re | tee timers-only-rm-re.log
ros2 trace stop timers-only-rm-re

ros2 trace start timers-only-edf-ro
./install/lib/rtss_evaluation/timers_only $duration edf ro | tee timers-only-edf-ro.log
ros2 trace stop timers-only-edf-ro

ros2 trace start timers-only-edf-re
./install/lib/rtss_evaluation/timers_only $duration edf re | tee timers-only-edf-re.log
ros2 trace stop timers-only-edf-re

ros2 trace start timers-only-events-ro
./install/lib/rtss_evaluation/timers_only $duration events ro | tee timers-only-events-ro.log
ros2 trace stop timers-only-events-ro

ros2 trace start timers-only-events-re
./install/lib/rtss_evaluation/timers_only $duration events re | tee timers-only-events-re.log
ros2 trace stop timers-only-events-re

ros2 trace start timers-only-default
./install/lib/rtss_evaluation/timers_only $duration default | tee timers-only-default.log
ros2 trace stop timers-only-default

cp -r ~/.ros/tracing/timers-only-* .
chown -R $SUDO_USER:$SUDO_USER timers-only-*