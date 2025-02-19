#!/bin/bash
set -e

# vcs import < src/ros2.repos src
sudo apt-get update
sudo apt install -y \
  babeltrace \
  libasio-dev \
  libacl1-dev \
  libfastcdr-dev \
  less \
  python3-pip \
  python3-pytest-cov \
  python3-flake8-blind-except \
  python3-flake8-class-newline \
  python3-flake8-deprecated \
  python3-pytest-repeat \
  python3-pytest-rerunfailures \
  \
  ros-dev-tools \
  ros-rolling-test-msgs \
  ros-rolling-tracetools-analysis \
  ros-rolling-tracetools-launch \
  ros-rolling-tracetools-trace \
  ros-rolling-performance-test-fixture \
  ros-rolling-mimick-vendor \
  ros-rolling-ros-testing \
  ros-rolling-rmw-cyclonedds-cpp \
  ros-rolling-ros2trace \
  ros-rolling-tracetools-analysis

pip3 install numpy==1.21.5 pandas==1.3.5 matplotlib==3.5.1 seaborn bokeh==2.4.3 psrecord==1.2
#sudo RTI_NC_LICENSE_ACCEPTED=yes apt-get install rti-connext-dds-6.0.1 -y

if [ -z "$ROS_DISTRO" ]; then
  source /opt/ros/rolling/setup.bash
  echo "source /opt/ros/rolling/setup.bash" >> ~/.bashrc
fi

rosdep update --rosdistro=$ROS_DISTRO
rosdep install --from-paths src --ignore-src -y --rosdistro=$ROS_DISTRO