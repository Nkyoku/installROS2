#!/bin/bash
# 
# Copyright (c) 2021 Jetsonhacks 
# MIT License

# Roughly follows the 'Install ROS From Source' procedures from:
#   https://index.ros.org/doc/ros2/Installation/Foxy/Linux-Development-Setup/
# mostly from: 
#   Dockerfile.ros.foxy
#   https://github.com/dusty-nv/jetson-containers
# 

# Exit on error
set -e

ROS_PKG=ros_base
ROS_DISTRO=foxy
# Core ROS2 workspace - the "underlay"
ROS_ROOT=/opt/ros/${ROS_DISTRO}
ARCH=$(uname --m)

# Suppress git warnings
git config --global advice.detachedHead false

locale  # check for UTF-8

sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Add the ROS 2 apt repository
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
		curl \
		wget \
		gnupg2 \
		lsb-release
sudo rm -rf /var/lib/apt/lists/*
    
wget --no-check-certificate https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc 
sudo apt-key add ros.asc
sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

# install development packages
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
		build-essential \
		cmake \
		git \
		libbullet-dev \
		libpython3-dev \
		python3-colcon-common-extensions \
		python3-flake8 \
		python3-pip \
		python3-wheel \
		python3-pytest-cov \
		python3-rosdep \
		python3-setuptools \
		python3-vcstool \
		python3-rosinstall-generator \
		libasio-dev \
		libtinyxml2-dev \
		libcunit1-dev
sudo rm -rf /var/lib/apt/lists/*
  
# install some pip packages needed for testing
python3 -m pip install -U \
		argcomplete \
		wheel \
		flake8-blind-except \
		flake8-builtins \
		flake8-class-newline \
		flake8-comprehensions \
		flake8-deprecated \
		flake8-docstrings \
		flake8-import-order \
		flake8-quotes \
		pytest-repeat \
		pytest-rerunfailures \
		pytest
        
# compile yaml-cpp-0.6, which some ROS packages may use (but is not in the 18.04 apt repo)
git clone --branch yaml-cpp-0.6.0 https://github.com/jbeder/yaml-cpp yaml-cpp-0.6 && \
    cd yaml-cpp-0.6 && \
    mkdir build && \
    cd build && \
    cmake -DBUILD_SHARED_LIBS=ON .. && \
    make -j$(nproc) && \
    sudo cp -f libyaml-cpp.so.0.6.0 /usr/lib/${ARCH}-linux-gnu/ && \
    sudo ln -sf /usr/lib/${ARCH}-linux-gnu/libyaml-cpp.so.0.6.0 /usr/lib/${ARCH}-linux-gnu/libyaml-cpp.so.0.6 && \
    cd ../../

# https://answers.ros.org/question/325245/minimal-ros2-installation/?answer=325249#post-id-325249
mkdir -p src
rosinstall_generator --deps --rosdistro ${ROS_DISTRO} ${ROS_PKG} launch_xml launch_yaml example_interfaces > ros2.${ROS_DISTRO}.${ROS_PKG}.rosinstall
cat ros2.${ROS_DISTRO}.${ROS_PKG}.rosinstall
vcs import src < ros2.${ROS_DISTRO}.${ROS_PKG}.rosinstall

# download unreleased packages
git clone -b foxy https://github.com/ros/diagnostics.git src/diagnostics
git clone --branch ros2 https://github.com/Kukanani/vision_msgs src/vision_msgs
git clone --branch ${ROS_DISTRO} https://github.com/ros2/demos demos
cp -r demos/demo_nodes_cpp src
cp -r demos/demo_nodes_py src
rm -r -f demos

# install dependencies using rosdep
sudo apt-get update
sudo rm -f /etc/ros/rosdep/sources.list.d/20-default.list
sudo rosdep init
rosdep update
rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y --skip-keys "console_bridge fastcdr fastrtps rti-connext-dds-5.3.1 urdfdom_headers qt_gui"
sudo rm -rf /var/lib/apt/lists/*

# build it!
sudo colcon build --merge-install --install-base ${ROS_ROOT}
sudo colcon build --merge-install --install-base ${ROS_ROOT}
