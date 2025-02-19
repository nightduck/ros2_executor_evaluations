# RTAS 2025 Artifact Evaluation

This branch and it's submodules contain code for the artifact evaluation of our RTAS 2025
submission. Instructions to replicate our results follow.

# Setup

The official reviewers have access to a pre-setup machine and can skip to the evaluation section.

The general public will need to setup their own test system using a Raspberry Pi Model 4B with 4GB
of RAM.

It must be running Ubuntu 20.04. This can be created using the 
(Raspberry Pi Imager)[https://www.raspberrypi.com/software/]. When selecting the OS, select
"Other General Purpose OS > Ubuntu Server 20.04.5 LTS"

TODO: Instructions on setting up Pi
TODO: Instructions on setting clock settings and letting nonroot users change sched_params

Clone the repository with

    git clone --recursive https://github.com/nightduck/ros2_executor_evaluations.git -b rtas2025_ae

Install any remaining dependencies with

		cd ros2_executor_evaluations
		source /opt/ros/rolling/setup.bash
		./setup.sh

It may prompt you for your password.

You then need to build the system. It must be built on the Pi because ROS2 doesn't support cross
compilation. Note that because it is being built on the Pi, the following command will take 3 hours.
Feel free to run it in a screen terminal

    ./build.sh

# Run Experiments

After building, source the install

    source install/setup.bash

Then you can run the experiments. Each of the scripts below has several tests to run, and runs each
for 5 minutes by default, taking 1-2 hours total. To run abbreviated (or longer) tests, these
scripts can be editted. They each have a variable called `duration` that is set to 300 seconds by
default. Revise that as needed. Then execute the following

		sudo env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./timers_only_benchmark.sh
		./autoware_benchmark.sh

After running the experiments, run the data processing scripts to generate graphs. (Source the venv)

		source venv/bin/activate
		python3 process_evaluation_data.py

The figures will be in the `figures/` filter