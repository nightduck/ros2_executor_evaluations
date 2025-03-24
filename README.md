# RTAS 2025 Artifact Evaluation

This branch and it's submodules contain code for the artifact evaluation of our RTAS 2025
submission. Instructions to replicate our results follow.

## Setup

You will need to setup your own test system using a Raspberry Pi Model 4B with 4GB
of RAM.

It must be running Ubuntu 20.04. This can be created using the 
[Raspberry Pi Imager](https://www.raspberrypi.com/software/). When selecting the OS, select
"Other General Purpose OS > Ubuntu > Ubuntu Server 20.04.5 LTS (64-bit)"

You must install ROS2 Rolling on the Pi. Following the instructions [here](https://docs.ros.org/en/rolling/Installation/Ubuntu-Install-Debs.html).

We need to set a constant CPU frequency. Do so with the following

    # Enter a root shell
    sudo su

    systemctl disable ondemand
    echo performance | tee \
      /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
    echo 1500000 | tee \
      /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq >/dev/null
    echo 1500000 | tee \
      /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq >/dev/null
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

After building, source the install.

    source install/setup.bash

This has to be done after opening each new terminal. To source automatically, you can add this command to your `~/.bashrc` file.

    echo "source path/to/ros2_executor_evaluations/install/setup.bash" >> ~/.bashrc

Then you can run the experiments. Each of the scripts below has several tests to run, and runs each
for 5 minutes by default, taking 1-2 hours total. To run abbreviated (or longer) tests, these
scripts can be editted. They each have a variable called `duration` that is set to 300 seconds by
default. Revise that as needed. Then execute the following

    sudo -E ./timers_only_benchmark.sh
    sudo -E ./autoware_benchmark.sh

## Simplified Experiments

The provided scripts run for ~100 minutes. For a shorter run, edit the `duration` variable in both `timers_only_benchmark.sh` and `autoware_benchmark.sh`. It is set to 300 seconds by default, edit to a lower value, such as 5. Then run the some the same scripts

    source install/setup.bash
    sudo -E ./timers_only_benchmark.sh
    sudo -E ./autoware_benchmark.sh

## View Data

After running the experiments, run the data processing scripts to generate graphs. (Source the venv)

    python3 process_evaluation_data.py

The figures will be in the `figures/` folder. scp them off of the machine for viewing. These will correspond to Figs 3,4,5, and 8, plus some additional figures that weren't included in the figure.


# Evaluation for Section VIII.B

Below instructions for evaluating the artifact associated with our paper on comparing end-to-end latencies in ROS 2 scheduling.

## System Requirements

- **Operating System**: Linux (Ubuntu 20.04 or later recommended)
- **RAM**: Minimum 8 GB
- **CPU**: Minimum 4 cores
- **Disk Space**: Minimum 10 GB free space
- **Docker**: Ensure Docker is installed and running
- **VS Code**: Ensure Visual Studio Code is installed with the Remote - Containers extension

## Packaged Artifact

The artifact is packaged as a Docker container. You can find the Dockerfile and configuration files in the `.devcontainer` directory.

## Setup Instructions

### Using the Packaged Artifact

1. **Clone the Repository**:

    ```sh
    git clone https://github.com/tu-dortmund-ls12-rt/Periodic-ROS2.git
    cd Periodic-ROS2
    ```

2. **Open in VS Code**:
    Open the repository in Visual Studio Code. You should see a prompt to reopen the folder in a container. Click on "Reopen in Container".

3. **Build and Run the Container**:
    The container will automatically build and set up the environment. This may take a few minutes.

4. **Run the Evaluation**:
    Once the container is ready, open a terminal in VS Code and run:

    ```sh
    python3 evaluation.py --num_task_sets 1000
    ```

### Setting Up on a Different Machine

If you prefer to set up the artifact on a different machine without using the Docker container, follow these steps:

1. **Install Dependencies**:
    Ensure you have Python 3, pip, and the required libraries installed:

    ```sh
    sudo apt-get update
    sudo apt-get install -y python3-pip
    pip3 install matplotlib tabulate scipy
    ```

2. **Clone the Repository**:

    ```sh
    git clone https://github.com/tu-dortmund-ls12-rt/Periodic-ROS2.git
    cd Periodic-ROS2
    ```

3. **Run the Evaluation**:

    ```sh
    python3 evaluation.py --num_task_sets 1000
    ```

## Reproducing Results

The evaluation script will reproduce the results presented in the paper. Specifically, it will generate synthetic task sets, calculate response times and end-to-end latencies, and produce visualizations similar to those in the paper. Depending on the hardware, the evaluation may take up to 10 minutes to complete. During the scripts, new windows with plots will be opened. Close these windows to continue the evaluation, until the script finishes.

### Figures and Outputs

- **evaluation_plot.png**: Histograms of normalized reduction in end-to-end latency.
- **Terminal**: Statistical values of RM and ROS 2 default end-to-end latencies.

## Simplified Experiments

For a quicker evaluation, you can reduce the number of task sets generated by passing a smaller value to the `--num_task_sets` parameter when running the `evaluation.py` script. By default, the script generates 1000 task sets. You can reduce this number to 100 or 10 to speed up the evaluation.

```sh
# Change the number of task sets from 1000 to a smaller number, e.g., 100
python3 evaluation.py --num_task_sets 100
```