#!/bin/bash
# ==============================================================================
#  Entrypoint — Inizializza l'ambiente ROS Jazzy e lancia il comando richiesto
# ==============================================================================

set -e

source /opt/ros/jazzy/setup.bash

if [ -f /home/rosuser/quadruped-navigation/install/setup.bash ]; then
    source /home/rosuser/quadruped-navigation/install/setup.bash
fi

exec "$@"
