---
title: Docker in Docker
date: "2023-08-27"
author: alex
---
[toc]
***

![docker-logo]({static}/images/2024/dind/docker-512.png)


# Introduction

In simple terms, Docker Inside Docker involves running Docker within a Docker container.

These are the major use cases that I know of for doing this:

1. Running an application to manage docker from a container (Example of this is 
   [portainer][portainer]).
2. Building docker containers from within a container
   - CI/CD pipelines that build and push docker images to a container registry.
   - Modern CI/CD systems that support Docker-based runners
3. Container isolation for: multi-tenancy, enhanced security, resource management.
   - Sandboxed environments
   - For experimental purposes on your local development workstation.
   - Resource isolation between different groups or development teams.

This use cases bring the following benefits ([Quote][quote1]):

1. Isolated Development and Testing:\
   Running Docker inside Docker allows developers to create isolated environments specifically
   tailored for their applications. This ensures that dependencies, configurations, and runtime
   environments remain consistent across different development stages, making it easier to
   reproduce and debug issues.
2. Enhanced Security and Isolation:\
   Running Docker inside Docker allows developers to create isolated environments specifically
   tailored for their applications. This ensures that dependencies, configurations, and runtime
   environments remain consistent across different development stages, making it easier to
   reproduce and debug issues.
3. Simplified CI/CD Pipelines:\
   Docker Inside Docker is widely used in Continuous Integration and Continuous Deployment (CI/CD)
   workflows. It enables the creation of self-contained, disposable environments for building,
   testing, and deploying applications, allowing for faster and more reliable automation pipelines.
4. Multi-tenancy and Resource Management:\
   Nested containerization can be incredibly useful in scenarios where multiple teams or users
   require isolated environments on shared infrastructure. By launching Docker inside Docker,
   you can provide each team or user with a separate Docker engine, ensuring resource isolation and
   preventing interference between different applications.


There are a number of approaches for doing this depending on the use case one
may be more appropriate than others:

1. Mounting `/var/run/docker.sock`
2. Run Docker in Docker using DnD
3. Run Docker in Docker using Sysbox run-time
4. Don't run Docker in Docker

See [here][article].

# Method 1: Mounting `/var/run/docker.sock`

![docker-unix-socket]({static}/images/2024/dind/docker-docker-unix-socket.png)

`/var/run/docker.sock` is the default Unix socket. Sockets are meant for communication
between processes on the same host.

Docker daemon by default listens to `docker.sock`. If you are on the same host where the Docker
daemon is running, you can use the `/var/run/docker.sock` to manage containers. meaning you can
mount the Docker socket from the host into the container

For example, if you run the following command, it will return the version of the docker engine.

```bash
curl --unix-socket /var/run/docker.sock http://localhost/version
```

To run docker inside docker, all you have to do is run docker with the default Unix socket
`docker.sock` as a volume.

For example,

```
docker run -v /var/run/docker.sock:/var/run/docker.sock \
           -ti docker
```

**Just a word of caution**: If your container gets access to `docker.sock`, it means it has
more privileges over your docker daemon. So when used in real projects, understand the
security risks, and use it.

Now, from within the container, you should be able to execute docker commands for building and
pushing images to the registry.

Here, the actual docker operations happen on the VM host running your base docker container
rather than from within the container. Meaning, even though you are executing the docker commands
from within the container, you are instructing the docker client to connect to the VM host
docker-engine through docker.sock

This method is the way to run applications like [portainer][portainer] which are used
to manage docker environments.

![portainer]({static}/images/2024/dind/portainer-infrastructure.png)


Because of the security implications I wouldn't recommend this for building docker images or
for doing container isolation.

## docker.sock permission error

While using `docker.sock` you may get permission denied error. In that case, you need to change
the docker.sock permission to the following.

```bash
sudo chmod 666 /var/run/docker.sock
```

Also, you might have to add the `--privileged` flag to give privileged access.

The docker sock permission gets reset server restarts. To avoid this you need to add the
permission to system startup scripts.

For example, you can add the command to `/etc/rc.local` so that it runs automatically every time
your server starts up.

Also, Keep in mind that `666` permissions open a security hole.

# Method 2: Docker in Docker Using DinD

![docker-dind]({static}/images/2024/dind/docker-dind-min.png)


This method actually creates a child container inside a Docker container. Use this method only if you
really want to have the containers and images inside the container. Otherwise, I would suggest you
use the first approach.

For this, you just need to use the official docker image with `dind` tag. The dind image is baked
with the required utilities for Docker to run inside a docker container.

**Note**: This requires your container to be run in privileged mode.

- Step 1: Create a container named `dind-test` with `docker:dind` image
  '''bash
  docker run --privileged -d --name dind-test docker:dind
  ```
- Step 2: Log in to the container using exec.
  ```bash
  docker exec -it dind-test /bin/sh
  ```
- Step 3: Once you are inside the container, execute docker commands as needed.

This approach is usually geared towards creating Docker images within docker.  The main
disadvantage is that you are still runnning your container in _priviledge mode_ which
can be considered a security risk.

# Method 3: Docker in Docker Using Sysbox Runtime

![sysbox-diag]({static}/images/2024/dind/sysbox-diagram.png)


This method avoids running containers in priviledge mode by using the [sysbox][sysbox] runtime.

[Sysbox][sysbox] is an open-source and free container runtime (a specialized "runc"), that
enhances containers in two key ways:

- Improves container isolation:
  - Linux user-namespace on all containers (i.e., root user in the container has zero
    privileges on the host).
  - Virtualizes portions of procfs & sysfs inside the container.
  - Hides host info inside the container.
  - Locks the container's initial mounts, and more.
- Enables containers to run same workloads as VMs:
  - With [Sysbox][sysbox], containers can run system-level software such as systemd, Docker,
    Kubernetes, K3s, buildx, legacy apps, and more seamlessly & securely.
  - This software can run inside [Sysbox][sysbox] containers without modification and without
    using special versions of the software (e.g., rootless variants).
  - No privileged containers, no complex images, no tricky entrypoints, no special volume mounts, etc.

If you create a container using [sysbox][sysbox] runtime, it can create virtual environments
inside a container that is capable of running systemd, docker, kubernetes without having
privileged access to the underlying host system.

- Step 1: Install the sysbox runtime environment.
- Step 2: Once you have the sysbox runtime available, all you have to do is start the docker
  container with a sysbox runtime flag as shown below. Here we are using the official docker dind
  image.
  ```bash
  docker run --runtime=sysbox-runc --name sysbox-dind -d docker:dind
  ```
- Step 3: Now take an exec session to the sysbox-dind container.
  ```bash
  docker exec -it sysbox-dind /bin/sh
  ```
- Step 4: Once you are inside the container, execute docker commands as needed.


This method is intented for sandboxing, running Container as VMs, isolating, etc.  Let's
you run _system_ software that requires special priviledges into isolated and secure
environment.

[Sysbox][sysbox] solves problems such as:

- Enhancing the isolation of containerized microservices (root in the container maps to an
  unprivileged user on the host).
- Enabling a highly capable root user inside the container without compromising host security.
- Securing CI/CD pipelines by enabling Docker-in-Docker (DinD) or Kubernetes-in-Docker (KinD)
  without insecure privileged containers or host Docker socket mounts.
- Enabling the use of containers as "VM-like" environments for development, local testing,
  learning, etc., with strong isolation and the ability to run systemd, Docker, IDEs, and more
  inside the container.
- Running legacy apps inside containers (instead of less efficient VMs).
- Replacing VMs with an easier, faster, more efficient, and more portable container-based
  alternative, one that can be deployed across cloud environments easily.
- Partitioning bare-metal hosts into multiple isolated compute environments with 2X the density
  of VMs (i.e., deploy twice as many VM-like containers as VMs on the same hardware at the same
  performance).
- Partitioning cloud instances (e.g., EC2, GCP, etc.) into multiple isolated compute
  environments without resorting to expensive nested virtualization.

# Method 4: Don't run docker in docker

If you only need to docker images (For example inside a CI/CD pipeline with Docker or K8s
executors), you can simply use a tool that is focused on building docker images **without**
using docker itself.  For example:

![buildah]({static}/images/2024/dind/buildah-logo_sm.png)

- [buildah](https://github.com/containers/buildah)
- [img](https://github.com/genuinetools/img)

These two are available in [void linux][void]

# Conclusions

Running docker in docker used to be a requirement to build docker images from within 
a docker container (as part of a CI/CD pipeline based on docker container executors).

Today in 2024, that is no longer needed, one you can just use a solution as indicated
in **Method 4**.

However, docker in docker solutions are still needed to run things like
[portainer][portainer] using **Method 1** to run docker management solutions from
within a container.  I remember seeing other applications such as Infobox Blox One DDI
that took a similar approach.

Lastly, there is still a need to run Containers as VMs or to create Docker like environments
for testing and isolation.  This use case exists, but I find it a bit niche.  In my view,
you are better off runninge these as a full VM which gives you better flexibility and more
discrete isolation.  It is less efficient, but in today's world, the overhead due to virtualization
is minimal compared to the complexity these special solutions bring.

  [void]: https://voidlinux.org/
  [portainer]: https://www.portainer.io/
  [quote1]: https://medium.com/@shivam77kushwah/docker-inside-docker-e0483c51cc2c
  [sysbox]: https://github.com/nestybox/sysbox
  [article]: https://devopscube.com/run-docker-in-docker/




