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

Pull the image: `docker pull ros:jazzy-ros-base`
Create a container: `docker run --name <container_name> <image_name>`
Go into the container: `docker exec -it <container_name> bash`