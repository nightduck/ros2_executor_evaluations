#!/bin/bash

duration=5

source install/setup.bash

# TODO: ros2 trace start/stop don't actually work and result in empty traces

rm -r ~/.ros/tracing/timers-only-rm-ro
ros2 trace start timers-only-rm-ro
sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./install/lib/rtss_evaluation/timers_only $duration rm ro | tee timers-only-rm-ro.log
ros2 trace stop timers-only-rm-ro

rm -r ~/.ros/tracing/timers-only-rm-re
ros2 trace start timers-only-rm-re
sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./install/lib/rtss_evaluation/timers_only $duration rm re | tee timers-only-rm-re.log
ros2 trace stop timers-only-rm-re

rm -r ~/.ros/tracing/timers-only-edf-ro
ros2 trace start timers-only-edf-ro
sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./install/lib/rtss_evaluation/timers_only $duration edf ro | tee timers-only-edf-ro.log
ros2 trace stop timers-only-edf-ro

rm -r ~/.ros/tracing/timers-only-edf-re
ros2 trace start timers-only-edf-re
sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./install/lib/rtss_evaluation/timers_only $duration edf re | tee timers-only-edf-re.log
ros2 trace stop timers-only-edf-re

rm -r ~/.ros/tracing/timers-only-events-ro
ros2 trace start timers-only-events-ro
sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./install/lib/rtss_evaluation/timers_only $duration events ro | tee timers-only-events-ro.log
ros2 trace stop timers-only-events-ro

rm -r ~/.ros/tracing/timers-only-events-re
ros2 trace start timers-only-events-re
sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./install/lib/rtss_evaluation/timers_only $duration events re | tee timers-only-events-re.log
ros2 trace stop timers-only-events-re

rm -r ~/.ros/tracing/timers-only-default
ros2 trace start timers-only-default
sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./install/lib/rtss_evaluation/timers_only $duration default | tee timers-only-default.log
ros2 trace stop timers-only-default