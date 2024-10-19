#!/bin/bash

# Default value for the benchmark duration
duration=10

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

python3 $(ros2 pkg prefix --share autoware_reference_system)/scripts/benchmark.py $duration \
        autoware_default_singlethreaded,autoware_default_events,autoware_default_rm,autoware_default_edf

mkdir -p data/autoware_benchmark
cp -r ~/.ros/benchmark_autoware_reference_system/latest/* data/autoware_benchmark/