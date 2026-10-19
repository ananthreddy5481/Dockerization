# DOCKER

Docker is a platform that allows you to package and run applications in isolated environments.

Installing and configuring everything manually on another computer can be difficult. Different computers might have different software versions, leading to compatibility problems.


## Components of Docker

Docker Engine : it consists of docker daemon , that handles the creation and management of containers.

Docker File : it is a file that contains the steps to create a docker image.

Docker Image : a blueprint on how to build the docker containers it contains info related to dependencies and application code.

Docker container : the instance of the docker image. which will give the application functionality in a separate environment. changes in the container will not affect the image. 

Docker Hub : repository service and it is a cloud based service where people push their Docker Container Images and also pull the Docker Container Images from the Docker Hub anytime
or anywhere via the internet.



## Working flow

```
Dockerfile (Created by Developer)
            |
            v
Docker Daemon (Reads Instructions)
            |
            v
Executes Instructions One by One
            |
            v
      Docker Image Created
            |
            v
  Docker Container Instances Created
            |
            v
    Make Changes in Containers
            |
            v
  Original Docker Image Unchanged
  ```

  ## How to make a docker image and how to make a Docker cointainer

**1 - Create **dockerfile****
   create a file named **```Dockerfile```** 
   write instructions into that file.

   for example : 
   ```
   FROM ubuntu:24.04
   RUN apt-get update && apt-get install -y curl
   CMD ["bash"]
   ```
   **FROM** - specifies the base image that we need to use, for example here we need Linux to run our application but to use that we need to
   have that image
   **RUN** - the command to run inside the linux environment 
   **CMD** - changes the shell from /bin/sh to bash shell.


   **2 - Build the Docker image**

   ```
   docker build -t my-image .
   ```
   **```docker build```** -  builds an image. 
   **```-t ```** - assigns the name for the image. (in current directory)

   **3 - Create and Run a Docker Container** 
   ```
   docker run -it --name my-container my-image
   ```
   **```-it```** - gives a temp terminal(linux terminal or command prompt based on the application or image created using dockerfile)
   **```--name```** - assigns name to that docker container from the specified image.

   **Usable tools**

   **```docker images```** - to list all the images available 
   **``docker ps``** - to check containers running 
   **``docker stop <container_id_or_name>``**  - to stop container.
   **``docker restart <container_id_or_name>``**  - to restart container.
   **``docker rm <container_id_or_name>``**  - to remove container ( can use -f flag to force remove).

