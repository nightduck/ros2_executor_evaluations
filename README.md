# RTAS 2025 Artifact Evaluation

This branch and it's submodules contain code for the artifact evaluation of our RTAS 2025
submission. Instructions to replicate our results follow.

## Setup

You will need to setup your own test system using a Raspberry Pi Model 4B with 4GB
of RAM.

It must be running Ubuntu 20.04. This can be created using the 
[Raspberry Pi Imager](https://www.raspberrypi.com/software/). When selecting the OS, select
"Other General Purpose OS > Ubuntu > Ubuntu Server 20.04.5 LTS (64-bit)"

You must install ROS2 Rolling on the Pi. Following the instructions [here](https://docs.ros.org/en/rolling/Installation/Ubuntu-Install-Debs.html). Use the ROS-Base Install instructions.

We need to set a constant CPU frequency. Do so with the following

    # Enter a root shell
    sudo su

    systemctl disable ondemand
    echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
    echo 1500000 | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq >/dev/null
    echo 1500000 | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq >/dev/null
    echo 1 | tee /sys/devices/system/cpu/cpu*/cpufreq/stats/reset >/dev/null

`Ctrl+D` to exit out of the root shell.

Clone the repository with

    git clone --recursive https://github.com/nightduck/ros2_executor_evaluations.git -b rtas2025_ae

Install any remaining dependencies with

		cd ros2_executor_evaluations
		./setup.sh

It may prompt you for your password. Afterwards, close and reopen the terminal so the environmental
changes can take effect.

You then need to build the system. It must be built on the Pi because ROS2 doesn't support cross
compilation. Note that because it is being built on the Pi, the following command will take 3 hours.
Feel free to run it in a screen terminal

    ./build.sh

## Run Experiments

After building, source the install

    source install/setup.bash

Then you can run the experiments. Each of the scripts below has several tests to run, and runs each
for 5 minutes by default, taking 1-2 hours total. To run abbreviated (or longer) tests, these
scripts can be editted. They each have a variable called `duration` that is set to 300 seconds by
default. Revise that as needed. Then execute the following

		sudo -E ./timers_only_benchmark.sh
		sudo -E ./autoware_benchmark.sh

## View Data

After running the experiments, run the data processing scripts to generate graphs. (Source the venv)

		python3 process_evaluation_data.py

The figures will be in the `figures/` filter. scp them off of the machine for viewing