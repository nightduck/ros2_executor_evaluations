#!/bin/bash

# Default value for the benchmark duration
duration=5

# Check if a command line argument is provided
if [ $# -eq 1 ]; then
  # Validate the input argument as an integer
  if [[ $1 =~ ^[0-9]+$ ]]; then
    duration=$1
  else
    echo "Invalid input. Usage: $0 [duration]"
    exit 1
  fi
fi

colcon build \
    --merge-install \
    --symlink-install \
    --packages-select autoware_reference_system \
    --cmake-force-configure --cmake-args -DRUN_BENCHMARK=ON

python3 $(ros2 pkg prefix --share autoware_reference_system)/scripts/benchmark.py \
    $duration 'autoware_*'