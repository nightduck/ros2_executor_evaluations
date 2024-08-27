#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Script needs root, please run: "
   echo "sudo env PATH=\"\$PATH\" LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH\" !! "
   # sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./timers_only_benchmark_uniprocessor.sh
   exit 1
fi

duration=5
UU=60
HU=80
OU=90

mkdir -p data
rm -r data/*
rm -r ~/.ros/tracing/trace-timers-only.*
source /opt/ros/rolling/setup.bash
source install/setup.bash

ros2 trace start trace-timers-only.rm.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration rm | tee trace-timers-only.rm.$UU.log
ros2 trace stop trace-timers-only.rm.$UU
mkdir -p data/response_time.rm.$UU/
mv *.node.txt data/response_time.rm.$UU/

ros2 trace start trace-timers-only.edf.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration edf | tee trace-timers-only.edf.$UU.log
ros2 trace stop trace-timers-only.edf.$UU
mkdir -p data/response_time.edf.$UU/
mv *.node.txt data/response_time.edf.$UU/

# ros2 trace start trace-timers-only.fifo.$UU
# taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration fifo | tee trace-timers-only.fifo.$UU.log
# ros2 trace stop trace-timers-only.fifo.$UU

ros2 trace start trace-timers-only.events.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration events | tee trace-timers-only.events.$UU.log
ros2 trace stop trace-timers-only.events.$UU
mkdir -p data/response_time.events.$UU/
mv *.node.txt data/response_time.events.$UU/

ros2 trace start trace-timers-only.static.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration static | tee trace-timers-only.static.$UU.log
ros2 trace stop trace-timers-only.static.$UU
mkdir -p data/response_time.static.$UU/
mv *.node.txt data/response_time.static.$UU/

ros2 trace start trace-timers-only.default.$UU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only $duration default | tee trace-timers-only.default.$UU.log
ros2 trace stop trace-timers-only.default.$UU
mkdir -p data/response_time.default.$UU/
mv *.node.txt data/response_time.default.$UU/

ros2 trace start trace-timers-only.rm.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration rm | tee trace-timers-only.rm.$HU.log
ros2 trace stop trace-timers-only.rm.$HU
mkdir -p data/response_time.rm.$HU/
mv *.node.txt data/response_time.rm.$HU/

ros2 trace start trace-timers-only.edf.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration edf | tee trace-timers-only.edf.$HU.log
ros2 trace stop trace-timers-only.edf.$HU
mkdir -p data/response_time.edf.$HU/
mv *.node.txt data/response_time.edf.$HU/

# ros2 trace start trace-timers-only.fifo.$HU
# taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration fifo | tee trace-timers-only.fifo.$HU.log
# ros2 trace stop trace-timers-only.fifo.$HU

ros2 trace start trace-timers-only.events.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration events | tee trace-timers-only.events.$HU.log
ros2 trace stop trace-timers-only.events.$HU
mkdir -p data/response_time.events.$HU/
mv *.node.txt data/response_time.events.$HU/

ros2 trace start trace-timers-only.static.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration static | tee trace-timers-only.static.$HU.log
ros2 trace stop trace-timers-only.static.$HU
mkdir -p data/response_time.static.$HU/
mv *.node.txt data/response_time.static.$HU/

ros2 trace start trace-timers-only.default.$HU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_high_utilization $duration default | tee trace-timers-only.default.$HU.log
ros2 trace stop trace-timers-only.default.$HU
mkdir -p data/response_time.default.$HU/
mv *.node.txt data/response_time.default.$HU/

ros2 trace start trace-timers-only.rm.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration rm | tee trace-timers-only.rm.$OU.log
ros2 trace stop trace-timers-only.rm.$OU
mkdir -p data/response_time.rm.$OU/
mv *.node.txt data/response_time.rm.$OU/

ros2 trace start trace-timers-only.edf.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration edf | tee trace-timers-only.edf.$OU.log
ros2 trace stop trace-timers-only.edf.$OU
mkdir -p data/response_time.edf.$OU/
mv *.node.txt data/response_time.edf.$OU/

# ros2 trace start trace-timers-only.fifo.$OU
# taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration fifo | tee trace-timers-only.fifo.$OU.log
# ros2 trace stop trace-timers-only.fifo.$OU

ros2 trace start trace-timers-only.events.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration events | tee trace-timers-only.events.$OU.log
ros2 trace stop trace-timers-only.events.$OU
mkdir -p data/response_time.events.$OU/
mv *.node.txt data/response_time.events.$OU/

ros2 trace start trace-timers-only.static.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration static | tee trace-timers-only.static.$OU.log
ros2 trace stop trace-timers-only.static.$OU
mkdir -p data/response_time.static.$OU/
mv *.node.txt data/response_time.static.$OU/

ros2 trace start trace-timers-only.default.$OU
taskset 0x8 ./install/lib/rtss_evaluation/timers_only_over_utilization $duration default | tee trace-timers-only.default.$OU.log
ros2 trace stop trace-timers-only.default.$OU
mkdir -p data/response_time.default.$OU/
mv *.node.txt data/response_time.default.$OU/

cp -r ~/.ros/tracing/trace-timers-only.* data/
mv trace-timers-only.* data/
chown -R $SUDO_USER:$SUDO_USER data/
