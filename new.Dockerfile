
FROM ros:jazzy-ros-base

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ros-jazzy-rviz2 \
    ros-jazzy-ros-gz \
    ros-jazzy-ros2bag \
    ros-jazzy-rosbag2-storage-default-plugins

RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc
 
CMD ["/bin/bash"]
