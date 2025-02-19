#!/bin/bash

# Default value for the benchmark duration
duration=300

#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "Script needs root, please run: "
   echo "sudo !! "
   exit 1
fi

source /opt/ros/rolling/setup.bash
source install/setup.bash

directory=$(ros2 pkg prefix --share autoware_reference_system)/scripts
python3 $directory/benchmark.py $duration \
        autoware_default_singlethreaded,autoware_default_events,autoware_default_rm,autoware_default_staticsinglethreaded

mkdir -p data/autoware_benchmark
cp -r ~/.ros/benchmark_autoware_reference_system/latest/* data/autoware_benchmark/