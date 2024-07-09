##############################################
# Created from template ros2.dockerfile.jinja
##############################################

###########################################
# Base image
###########################################
FROM arm64v8/ubuntu:24.04 AS base
ENV DEBIAN_FRONTEND=noninteractive

# Install language
RUN apt-get update && apt-get install -y \
  locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8

# Install timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get -y upgrade \
    && rm -rf /var/lib/apt/lists/*

# Install common programs
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
    lsb-release \
    sudo \
    software-properties-common \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install ROS2
RUN sudo add-apt-repository universe \
  && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null \
  && apt-get update && apt-get install -y --no-install-recommends \
    ros-rolling-ros-base \
    python3-argcomplete \
  && rm -rf /var/lib/apt/lists/*

ENV ROS_DISTRO=rolling
ENV AMENT_PREFIX_PATH=/opt/ros/rolling
ENV COLCON_PREFIX_PATH=/opt/ros/rolling
ENV LD_LIBRARY_PATH=/opt/ros/rolling/lib
ENV PATH=/opt/ros/rolling/bin:$PATH
ENV PYTHONPATH=/opt/ros/rolling/local/lib/python3.10/dist-packages:/opt/ros/rolling/lib/python3.10/site-packages
ENV ROS_PYTHON_VERSION=3
ENV ROS_VERSION=2
ENV DEBIAN_FRONTEND=

###########################################
#  Develop image
###########################################
FROM base AS dev

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  bash-completion \
  build-essential \
  cmake \
  gdb \
  git \
  openssh-client \
  python3-argcomplete \
  python3-pip \
  ros-dev-tools \
  ros-rolling-ament-* \
  vim \
  && rm -rf /var/lib/apt/lists/*

RUN rosdep init || echo "rosdep already initialized"

# TODO: Fix this when Allison releases her updated rolling container or when Canonical realises they
# shouldn't have a default username sitting at UID 1000
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create a non-root user
# RUN groupadd -g $USER_GID $USERNAME
# RUN useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME
# Add sudo support for the non-root user
RUN apt-get update \
  && apt-get install -y  --no-install-recommends sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && rm -rf /var/lib/apt/lists/*

# Set up autocompletion for user
RUN apt-get update && apt-get install -y git-core bash-completion \
  && echo "if [ -f /opt/ros/${ROS_DISTRO}/setup.bash ]; then source /opt/ros/${ROS_DISTRO}/setup.bash; fi" >> /home/$USERNAME/.bashrc \
  && echo "if [ -f /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash ]; then source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash; fi" >> /home/$USERNAME/.bashrc \
  && rm -rf /var/lib/apt/lists/* 

ENV DEBIAN_FRONTEND=
ENV AMENT_CPPCHECK_ALLOW_SLOW_VERSIONS=1

###########################################
#  Image being launched
###########################################
FROM dev

RUN apt-get update \
  && apt install -y  --no-install-recommends \
      babeltrace \
      libasio-dev \
      libacl1-dev \
      libfastcdr-dev \
      less \
      python3-empy \
      python3-numpy \
      python3-pip \
      python3-pytest-cov \
      python3-flake8-blind-except \
      python3-flake8-class-newline \
      python3-flake8-deprecated \
      python3-pytest-repeat \
      python3-pytest-rerunfailures \
      python3-venv \
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

# # Make ssh dir
# RUN mkdir /root/.ssh/ && \
#     chmod 0700 /root/.ssh

# # Add the keys and set permissions
# ARG ssh_prv_key
# ARG ssh_pub_key
# RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
#     echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
#     chmod 600 /root/.ssh/id_rsa && \
#     chmod 600 /root/.ssh/id_rsa.pub

# # Create known_hosts
# COPY known_hosts /root/.ssh/known_hosts

# RUN git clone --recursive https://github.com/nightduck/rtss2024_paper.git /workspace
ADD . /workspace

WORKDIR /workspace

RUN python3 -m venv --system-site-packages .venv
ENV VIRTUAL_ENV=/workspace/.venv
ENV PATH=/workspace/.venv/bin:$PATH
RUN pip3 install bokeh==2.4.3 psrecord catkin_pkg

RUN rosdep update --rosdistro=$ROS_DISTRO && \
    rosdep install -y \
      --from-paths src \
      --ignore-src \
      --skip-keys " \
          fastcdr \
          rti-connext-dds-6.0.1 \
          urdfdom_headers" \
    && rm -rf /var/lib/apt/lists/*

ENV BUILD_TYPE=RelWithDebInfo
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
  . /workspace/.venv/bin/activate && \
  colcon build \
    --merge-install \
    --symlink-install \
    --packages-skip rt_nodes rt_msgs \
    --cmake-args "-DCMAKE_BUILD_TYPE=$BUILD_TYPE" "-DCMAKE_EXPORT_COMPILE_COMMANDS=On" \
    -Wall -Wextra -Wpedantic

# Set up auto-source of workspace for user
ARG WORKSPACE
RUN echo "if [ -f ${WORKSPACE}/install/setup.bash ]; then source ${WORKSPACE}/install/setup.bash; fi" >> /home/$USERNAME/.bashrc
RUN echo "if [ -f /workspace/.venv/bin/activate ]; then source /workspace/.venv/bin/activate; fi" >> /home/$USERNAME/.bashrc
