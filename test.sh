#!/bin/bash
set -e

if [ -f install/setup.bash ]; then source install/setup.bash; fi
colcon test --merge-install --packages-select rclcpp
colcon test-result --verbose
