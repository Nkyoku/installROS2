# installROS2
Scripts to install ROS2 (foxy) on the NVIDIA Jetson Development Kits  
This is a simple script to install ROS2 on the NVIDIA Jetson Development Kits.

The script roughly follows the 'Install ROS From Source' procedures from:  
[https://index.ros.org/doc/ros2/Installation/Foxy/Linux-Development-Setup/](https://index.ros.org/doc/ros2/Installation/Foxy/Linux-Development-Setup/)

Much of the code is taken from the dusty-nv Github repository jetson-containers. The dusty-nv jetson-containers should be used to create a Docker container for the ROS2 on the Jetson. For more information:  
```Dockerfile.ros.foxy``` [https://github.com/dusty-nv/jetson-containers](https://github.com/dusty-nv/jetson-containers)

## Usage
In order to run the script:  
```
cd ~
git clone https://github.com/Nkyoku/installROS2.git
cd installROS2
./installROS2.sh
```

After the installation, remove garbage
```
cd ~
sudo rm -rf installROS2
```

## Notes
<b>This script does not modify ~/.bashrc unline the original one.</b>

## Release Notes
<b>August, 2021</b>
* Tested on JetPack 4.6, L4T 32.6.1
* Tested on Jetson Nano 4GB
