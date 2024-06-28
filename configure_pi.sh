#!/bin/bash
set -e

if grep -q "Raspberry Pi 4" /sys/firmware/devicetree/base/model; then
  echo "Confirming this is a Pi Model 4..."
else
  echo "This is not a Raspberry Pi 4."
  exit 1
fi

# # Install ROS2
# apt update && sudo apt install locales
# locale-gen en_US en_US.UTF-8
# update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
# export LANG=en_US.UTF-8

# apt install software-properties-common
# add-apt-repository universe
# apt update && sudo apt install curl -y
# curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# apt update
# apt upgrade

# apt install -y \
#   babeltrace \
#   libasio-dev \
#   libacl1-dev \
#   libfastcdr-dev \
#   less \
#   sysstat \
#   u-boot-tools \
#   python3-pip \
#   python3-pytest-cov \
#   python3-flake8-blind-except \
#   python3-flake8-class-newline \
#   python3-flake8-deprecated \
#   python3-pytest-repeat \
#   python3-pytest-rerunfailures \
#   \
#   ros-rolling-base \
#   ros-dev-tools \
#   ros-rolling-test-msgs \
#   ros-rolling-tracetools-analysis \
#   ros-rolling-tracetools-launch \
#   ros-rolling-tracetools-trace \
#   ros-rolling-performance-test-fixture \
#   ros-rolling-mimick-vendor \
#   ros-rolling-ros-testing \
#   ros-rolling-rmw-cyclonedds-cpp \
#   ros-rolling-ros2trace \
#   ros-rolling-tracetools-analysis

# Install docker
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $USER
sudo newgrp docker

# TODO: Setup real-time kernel

# TODO: install lttng-modules-dkms

# Setup a constant CPU frequency
echo -n "setup constant CPU frequency to 1.50 GHz ... "
# disable ondemand governor
#systemctl disable ondemand

# set performance governor for all cpus
echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null

# set constant frequency
echo 1500000 | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq >/dev/null
echo 1500000 | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq >/dev/null

# reset frequency counters
echo 1 | tee /sys/devices/system/cpu/cpu*/cpufreq/stats/reset >/dev/null

echo done

sleep 1
# get freq info
echo `cpufreq-info | grep stats | cut -d ' ' -f 23-25`


dd if=/boot/firmware/boot.scr of=boot.scr.bak bs=72 skip=1

# Edit boot.script
sed '0,/setenv bootargs.*/{s/setenv bootargs.*/setenv bootargs "${bootargs} rcu_nocbs=2,3 nohz_full=2,3 isolcpus=2,3 irqaffinity=0,1 audit=0 watchdog=0 skew_tick=1 quiet splash"/}' boot.scr.bak > boot.script

# generate boot.scr
mkimage -A arm64 -O linux -T script -C none -d boot.script boot.scr

# replace boot.scr
mv boot.scr /boot/firmware/boot.scr

echo "Please reboot to apply changes"
