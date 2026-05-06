
FROM ros:jazzy-ros-base

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ros-jazzy-rviz2 \
    ros-jazzy-ros-gz \
    ros-jazzy-ros2bag \
    ros-jazzy-rosbag2-storage-default-plugins

RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc && \
    echo "export ROS_DOMAIN_ID=0" >> ~/.bashrc && \
    echo "export RMW_IMPLEMENTATION=rmw_fastrtps_cpp" >> ~/.bashrc
 
CMD ["/bin/bash"]
