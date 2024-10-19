#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Script needs root, please run: "
   echo "sudo env PATH=\"\$PATH\" LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH\" !! "
   # sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./many_to_many_benchmark_uniprocessor.sh
   exit 1
fi

duration=5

UU=60
HU=80
OU=90

rm -r ~/.ros/tracing/trace-many-to-many.*
source install/setup.bash

ros2 trace start trace-many-to-many.edf.uu
# chrt -f 50 taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration edf | tee trace-many-to-many.edf.uu.log
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration edf | tee trace-many-to-many.edf.uu.log
ros2 trace stop trace-many-to-many.edf.uu

ros2 trace start trace-many-to-many.rm.uu
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration rm | tee trace-many-to-many.rm.uu.log
ros2 trace stop trace-many-to-many.rm.uu

ros2 trace start trace-many-to-many.events.uu
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration events | tee trace-many-to-many.events.uu.log
ros2 trace stop trace-many-to-many.events.uu

ros2 trace start trace-many-to-many.default.uu
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration default | tee trace-many-to-many.default.uu.log
ros2 trace stop trace-many-to-many.default.uu

ros2 trace start trace-many-to-many.edf.hu
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration edf | tee trace-many-to-many.edf.hu.log
ros2 trace stop trace-many-to-many.edf.hu

ros2 trace start trace-many-to-many.rm.hu
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration rm | tee trace-many-to-many.rm.hu.log
ros2 trace stop trace-many-to-many.rm.hu

ros2 trace start trace-many-to-many.events.hu
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration events | tee trace-many-to-many.events.hu.log
ros2 trace stop trace-many-to-many.events.hu

ros2 trace start trace-many-to-many.default.hu
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration default | tee trace-many-to-many.default.hu.log
ros2 trace stop trace-many-to-many.default.hu

ros2 trace start trace-many-to-many.edf.ou
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration edf | tee trace-many-to-many.edf.ou.log
ros2 trace stop trace-many-to-many.edf.ou

ros2 trace start trace-many-to-many.rm.ou
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration rm | tee trace-many-to-many.rm.ou.log
ros2 trace stop trace-many-to-many.rm.ou

ros2 trace start trace-many-to-many.events.ou
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration events | tee trace-many-to-many.events.ou.log
ros2 trace stop trace-many-to-many.events.ou

ros2 trace start trace-many-to-many.default.ou
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration default | tee trace-many-to-many.default.ou.log
ros2 trace stop trace-many-to-many.default.ou

cp -r ~/.ros/tracing/trace-many-to-many.* ./data/
mv trace-many-to-many* ./data/
chown -R $SUDO_USER:$SUDO_USER data/trace-many-to-many.*
