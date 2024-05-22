#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Script needs root, please run: "
   echo "sudo env PATH=\"\$PATH\" LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH\" !! "
   # sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./timers_only_benchmark.sh
   exit 1
fi

duration=5
UU=60
HU=80
OU=90

rm -r ~/.ros/tracing/trace-timers-only.*
source /opt/ros/rolling/setup.bash
source install/setup.bash

ros2 trace start trace-timers-only.rm.ro.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration rm ro | tee trace-timers-only.rm.ro.$UU.log
ros2 trace stop trace-timers-only.rm.ro.$UU

ros2 trace start trace-timers-only.rm.re.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration rm re | tee trace-timers-only.rm.re.$UU.log
ros2 trace stop trace-timers-only.rm.re.$UU

ros2 trace start trace-timers-only.edf.ro.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration edf ro | tee trace-timers-only.edf.ro.$UU.log
ros2 trace stop trace-timers-only.edf.ro.$UU

ros2 trace start trace-timers-only.edf.re.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration edf re | tee trace-timers-only.edf.re.$UU.log
ros2 trace stop trace-timers-only.edf.re.$UU

# ros2 trace start trace-timers-only.fifo.ro.$UU
# taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration fifo ro | tee trace-timers-only.fifo.ro.$UU.log
# ros2 trace stop trace-timers-only.fifo.ro.$UU

# ros2 trace start trace-timers-only.fifo.re.$UU
# taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration fifo re | tee trace-timers-only.fifo.re.$UU.log
# ros2 trace stop trace-timers-only.fifo.re.$UU

ros2 trace start trace-timers-only.events.ro.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration events ro | tee trace-timers-only.events.ro.$UU.log
ros2 trace stop trace-timers-only.events.ro.$UU

ros2 trace start trace-timers-only.events.re.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration events re | tee trace-timers-only.events.re.$UU.log
ros2 trace stop trace-timers-only.events.re.$UU

ros2 trace start trace-timers-only.static.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration static | tee trace-timers-only.static.$UU.log
ros2 trace stop trace-timers-only.static.$UU

ros2 trace start trace-timers-only.default.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration default | tee trace-timers-only.default.$UU.log
ros2 trace stop trace-timers-only.default.$UU

ros2 trace start trace-timers-only.rm.ro.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration rm ro | tee trace-timers-only.rm.ro.$HU.log
ros2 trace stop trace-timers-only.rm.ro.$HU

ros2 trace start trace-timers-only.rm.re.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration rm re | tee trace-timers-only.rm.re.$HU.log
ros2 trace stop trace-timers-only.rm.re.$HU

ros2 trace start trace-timers-only.edf.ro.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration edf ro | tee trace-timers-only.edf.ro.$HU.log
ros2 trace stop trace-timers-only.edf.ro.$HU

ros2 trace start trace-timers-only.edf.re.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration edf re | tee trace-timers-only.edf.re.$HU.log
ros2 trace stop trace-timers-only.edf.re.$HU

# ros2 trace start trace-timers-only.fifo.ro.$HU
# taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration fifo ro | tee trace-timers-only.fifo.ro.$HU.log
# ros2 trace stop trace-timers-only.fifo.ro.$HU

# ros2 trace start trace-timers-only.fifo.re.$HU
# taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration fifo re | tee trace-timers-only.fifo.re.$HU.log
# ros2 trace stop trace-timers-only.fifo.re.$HU

ros2 trace start trace-timers-only.events.ro.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration events ro | tee trace-timers-only.events.ro.$HU.log
ros2 trace stop trace-timers-only.events.ro.$HU

ros2 trace start trace-timers-only.events.re.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration events re | tee trace-timers-only.events.re.$HU.log
ros2 trace stop trace-timers-only.events.re.$HU

ros2 trace start trace-timers-only.static.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration static | tee trace-timers-only.static.$HU.log
ros2 trace stop trace-timers-only.static.$HU

ros2 trace start trace-timers-only.default.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration default | tee trace-timers-only.default.$HU.log
ros2 trace stop trace-timers-only.default.$HU

ros2 trace start trace-timers-only.rm.ro.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration rm ro | tee trace-timers-only.rm.ro.$OU.log
ros2 trace stop trace-timers-only.rm.ro.$OU

ros2 trace start trace-timers-only.rm.re.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration rm re | tee trace-timers-only.rm.re.$OU.log
ros2 trace stop trace-timers-only.rm.re.$OU

ros2 trace start trace-timers-only.edf.ro.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration edf ro | tee trace-timers-only.edf.ro.$OU.log
ros2 trace stop trace-timers-only.edf.ro.$OU

ros2 trace start trace-timers-only.edf.re.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration edf re | tee trace-timers-only.edf.re.$OU.log
ros2 trace stop trace-timers-only.edf.re.$OU

# ros2 trace start trace-timers-only.fifo.ro.$OU
# taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration fifo ro | tee trace-timers-only.fifo.ro.$OU.log
# ros2 trace stop trace-timers-only.fifo.ro.$OU

# ros2 trace start trace-timers-only.fifo.re.$OU
# taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration fifo re | tee trace-timers-only.fifo.re.$OU.log
# ros2 trace stop trace-timers-only.fifo.re.$OU

ros2 trace start trace-timers-only.events.ro.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration events ro | tee trace-timers-only.events.ro.$OU.log
ros2 trace stop trace-timers-only.events.ro.$OU

ros2 trace start trace-timers-only.events.re.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration events re | tee trace-timers-only.events.re.$OU.log
ros2 trace stop trace-timers-only.events.re.$OU

ros2 trace start trace-timers-only.static.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration static | tee trace-timers-only.static.$OU.log
ros2 trace stop trace-timers-only.static.$OU

ros2 trace start trace-timers-only.default.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration default | tee trace-timers-only.default.$OU.log
ros2 trace stop trace-timers-only.default.$OU

cp -r ~/.ros/tracing/trace-timers-only.* .
chown -R $SUDO_USER:$SUDO_USER trace-timers-only.*
