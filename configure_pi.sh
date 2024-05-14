#!/bin/bash
set -e

if grep -q "Raspberry Pi 4" /sys/firmware/devicetree/base/model; then
  echo "Confirming this is a Pi Model 4..."
else
  echo "This is not a Raspberry Pi 4."
  exit 1
fi

sudo apt install -y sysstat u-boot-tools

# TODO: Install ROS2

# TODO: Setup real-time kernel

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
