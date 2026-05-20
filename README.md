# Quadruped-navigation
Simulazione di un robot quadrupede in un ambiente di simulazione Gazebo. implementare il controllo dinamico (FK e IK) con sensori. Successivamente implementare navigation e quant’altro. Future integrazioni: Computer Vision e Reinforcement Learning.

## Workflow

### Git repo submodules

The reposity has been organized to use submodules to safely distinguish versions.

```bash
git submodule add https://github.com/gabri00/quadruped-navigation.git modules/
git add .gitmodules modules/
```

### Docker

For interoperability and efficiency the project has been developed in a containerized environment, starting from the [ROS official images](https://hub.docker.com/_/ros/), we seleted the ROS2 Jazzy version.

Pull the image: cdocker pull ros:jazzy-ros-base`

### Usefull Commands
```bash
docker compose -f docker-compose.<platform>.yml up --build # To build the image and run the container
docker compose up           # To run the container
docker compose up -d        # To run the container in detached mode (without logs)
docker exec -it <CONTAINER_NAME> bash   # To go insede the container (CONTAINER_NAME=quadrped_navigation)
```

To allow display application:
```bash
echo 'xhost +local:docker > /dev/null' >> ~/.bashrc
```

### Architecture Notes
> [!IMPORTANT]
> Remember to set the correct architecture inside the Dockerfile. 