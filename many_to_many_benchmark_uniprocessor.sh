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

ros2 trace start trace-many-to-many.edf.$UU
# chrt -f 50 taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration edf | tee trace-many-to-many.edf.uu.log
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration edf | tee trace-many-to-many.edf.$UU.log
ros2 trace stop trace-many-to-many.edf.$UU
mkdir -p data/response_time.edf.$UU/
mv *.node.txt data/response_time.edf.$UU/

ros2 trace start trace-many-to-many.rm.$UU
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration rm | tee trace-many-to-many.rm.$UU.log
ros2 trace stop trace-many-to-many.rm.$UU
mkdir -p data/response_time.rm.$UU/
mv *.node.txt data/response_time.rm.$UU/

ros2 trace start trace-many-to-many.events.$UU
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration events | tee trace-many-to-many.events.$UU.log
ros2 trace stop trace-many-to-many.events.$UU
mkdir -p data/response_time.events.$UU/
mv *.node.txt data/response_time.events.$UU/

ros2 trace start trace-many-to-many.default.$UU
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration default | tee trace-many-to-many.default.$UU.log
ros2 trace stop trace-many-to-many.default.$UU
mkdir -p data/response_time.default.$UU/
mv *.node.txt data/response_time.default.$UU/

ros2 trace start trace-many-to-many.edf.$HU
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration edf | tee trace-many-to-many.edf.$HU.log
ros2 trace stop trace-many-to-many.edf.$HU
mkdir -p data/response_time.edf.$HU/
mv *.node.txt data/response_time.edf.$HU/

ros2 trace start trace-many-to-many.rm.$HU
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration rm | tee trace-many-to-many.rm.$HU.log
ros2 trace stop trace-many-to-many.rm.$HU
mkdir -p data/response_time.rm.$HU/
mv *.node.txt data/response_time.rm.$HU/

ros2 trace start trace-many-to-many.events.$HU
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration events | tee trace-many-to-many.events.$HU.log
ros2 trace stop trace-many-to-many.events.$HU
mkdir -p data/response_time.events.$HU/
mv *.node.txt data/response_time.events.$HU/

ros2 trace start trace-many-to-many.default.$HU
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration default | tee trace-many-to-many.default.$HU.log
ros2 trace stop trace-many-to-many.default.$HU
mkdir -p data/response_time.default.$HU/
mv *.node.txt data/response_time.default.$HU/

ros2 trace start trace-many-to-many.edf.$OU
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration edf | tee trace-many-to-many.edf.$OU.log
ros2 trace stop trace-many-to-many.edf.$OU
mkdir -p data/response_time.edf.$OU/
mv *.node.txt data/response_time.edf.$OU/

ros2 trace start trace-many-to-many.rm.$OU
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration rm | tee trace-many-to-many.rm.$OU.log
ros2 trace stop trace-many-to-many.rm.$OU
mkdir -p data/response_time.rm.$OU/
mv *.node.txt data/response_time.rm.$OU/

ros2 trace start trace-many-to-many.events.$OU
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration events | tee trace-many-to-many.events.$OU.log
ros2 trace stop trace-many-to-many.events.$OU
mkdir -p data/response_time.events.$OU/
mv *.node.txt data/response_time.events.$OU/

ros2 trace start trace-many-to-many.default.$OU
taskset 0x8 ./install/lib/paper_evaluation/many_to_many_pub $duration default | tee trace-many-to-many.default.$OU.log
ros2 trace stop trace-many-to-many.default.$OU
mkdir -p data/response_time.default.$OU/
mv *.node.txt data/response_time.default.$OU/

cp -r ~/.ros/tracing/trace-many-to-many.* ./data/
mv trace-many-to-many* ./data/
chown -R $SUDO_USER:$SUDO_USER data/trace-many-to-many.*
