#!/bin/bash
set -e

# Set the default build type
BUILD_TYPE=RelWithDebInfo

# Build with only one worker, otherwise the Pi will run out of memory
# export MAKEFLAGS="-j2"
colcon build \
        --merge-install \
        --symlink-install \
        --packages-skip rt_nodes rt_msgs \
        --cmake-args "-DCMAKE_BUILD_TYPE=$BUILD_TYPE" "-DCMAKE_EXPORT_COMPILE_COMMANDS=On" \
        -Wall -Wextra -Wpedantic -Wc++20-extensions
