#!/bin/bash
set -e

vcs import < src/ros2.repos src
sudo apt-get update
sudo apt install -y \
  ament-cmake \
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

pip3 install bokeh==2.4.3 psrecord
#sudo RTI_NC_LICENSE_ACCEPTED=yes apt-get install rti-connext-dds-6.0.1 -y
rosdep update --rosdistro=$ROS_DISTRO
rosdep install --from-paths src --ignore-src -y --rosdistro=$ROS_DISTRO