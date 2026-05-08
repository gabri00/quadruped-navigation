FROM ros:jazzy-ros-base

ENV DEBIAN_FRONTEND=noninteractive
ENV QT_X11_NO_MITSHM=1

SHELL ["/bin/bash", "-c"]

# ── Locale ───────────────────────────────────────────────────
RUN apt-get update && apt-get install -y locales && \
    locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8

# ── System packages ──────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    python3-setuptools \
    git \
    x11-apps \
    libx11-dev \
    mesa-utils \
    libgl1 \
    libglvnd-dev \
    libegl1 \
    libgl1-mesa-dri \
    cmake \
    build-essential \
    gcc \
    g++ \
    nano \
    net-tools \
    iproute2 \
    iputils-ping \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# ── ROS2 build tools ─────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    python3-rosinstall-generator \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init || true && rosdep update --rosdistro jazzy

# ── ROS2 packages ────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-jazzy-rviz2 \
    ros-jazzy-rviz-common \
    ros-jazzy-ros-gz \
    ros-jazzy-ros2bag \
    ros-jazzy-rosbag2-storage-default-plugins \
    ros-jazzy-ros2-control \
    ros-jazzy-ros2-controllers \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/ros2_ws/src
WORKDIR /root/ros2_ws

# ── Shell setup ───────────────────────────────────────────────
RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc && \
    echo "export ROS_DOMAIN_ID=0" >> ~/.bashrc && \
    echo "export RMW_IMPLEMENTATION=rmw_fastrtps_cpp" >> ~/.bashrc

CMD ["/bin/bash"]


### Old Dockerfile ###

# FROM ros:jazzy-ros-base

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     git \
#     ros-jazzy-rviz2 \
#     ros-jazzy-ros-gz \
#     ros-jazzy-ros2bag \
#     ros-jazzy-rosbag2-storage-default-plugins

# RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc && \
#     echo "export ROS_DOMAIN_ID=0" >> ~/.bashrc && \
#     echo "export RMW_IMPLEMENTATION=rmw_fastrtps_cpp" >> ~/.bashrc
 
# CMD ["/bin/bash"]
