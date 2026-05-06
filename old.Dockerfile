# ==============================================================================
#  ROS Desktop (con Rviz e GUI) — Multi-Architecture
#  Supporta: linux/amd64 (Linux/Windows) e linux/arm64 (Mac Apple Silicon)
#  ROS Distro: Jazzy Jalisco LTS (Ubuntu 24.04 LTS)
# ==============================================================================

FROM ros:jazzy-desktop

# ------------------------------------------------------------------------------
# Argomenti build (personalizzabili con --build-arg)
# ------------------------------------------------------------------------------
ARG USERNAME=rosuser
ARG USER_UID=1000
ARG USER_GID=1000

# ------------------------------------------------------------------------------
# Variabili d'ambiente
# ------------------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    ROS_DISTRO=jazzy \
    DISPLAY=${DISPLAY:-:0} \
    QT_X11_NO_MITSHM=1

# ------------------------------------------------------------------------------
# Dipendenze di sistema + pacchetti ROS con GUI
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Strumenti base
    git \
    curl \
    wget \
    vim \
    nano \
    bash-completion \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    # Supporto X11 / display grafico
    x11-apps \
    x11-xserver-utils \
    xauth \
    libx11-dev \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    mesa-utils \
    # Pacchetti ROS Jazzy Desktop completi
    ros-${ROS_DISTRO}-desktop-full \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-rqt \
    ros-${ROS_DISTRO}-rqt-common-plugins \
    ros-${ROS_DISTRO}-ros2bag \
    ros-${ROS_DISTRO}-rosbag2-storage-default-plugins \
    # Pulizia cache
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# Inizializza rosdep
# ------------------------------------------------------------------------------
RUN rosdep init 2>/dev/null || true && \
    rosdep update

# ------------------------------------------------------------------------------
# Crea un utente non-root
# ------------------------------------------------------------------------------
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
    usermod -aG video ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ------------------------------------------------------------------------------
# Setup ambiente ROS per l'utente
# ------------------------------------------------------------------------------
USER ${USERNAME}
WORKDIR /home/${USERNAME}

RUN mkdir -p /home/${USERNAME}/quadruped-navigation/src

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    echo "source /home/${USERNAME}/quadruped-navigation/install/setup.bash 2>/dev/null || true" >> ~/.bashrc && \
    echo "export ROS_DOMAIN_ID=0" >> ~/.bashrc && \
    echo "export RMW_IMPLEMENTATION=rmw_fastrtps_cpp" >> ~/.bashrc

# ------------------------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------------------------
COPY --chown=${USERNAME}:${USERNAME} entrypoint.sh /home/${USERNAME}/entrypoint.sh
USER root
RUN chmod +x /home/${USERNAME}/entrypoint.sh
USER ${USERNAME}

WORKDIR /home/${USERNAME}/quadruped-navigation
ENTRYPOINT ["/home/rosuser/entrypoint.sh"]
CMD ["bash"]
