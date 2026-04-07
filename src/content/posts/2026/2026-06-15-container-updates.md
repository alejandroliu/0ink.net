---
title: Updating containers
date: "2026-04-06"
author: alex
tags: software, python, ~remove
---
![]({static}/images/2026/docker-512.png)


Software needs to be updated in a regular basis.  Containers are no different in this regard.
Depending on how you are managing containers this can be tedious or simple.

# docker-compose

If you are using docker compose this quite easy.

1. Check for new images and download them:
	```bash
    docker-compose pull
    ```
2. Re-create containers with the updated images:
	```bash
    docker-compose up -d
    ```

If you just want to check without pulling:
```bash
docker-compose images
```
or
```bash
docker compose pull --dry-run
```

# podman

1. Check for updates
   ```bash
   podman image check --all
   ```
   or
   ```bash
   podman image check <image name>
   ```
2. Pull images (if updated)
   ```bash
   podman pull --policy=always <image name>
   ```

Podman can do automatic updates:

1. Create your container with:
   ```bash
   --label "io.containers.autoupdate=image"
   ```
2. Then you can run:
	```bash
    podman auto-update
    ```

# Docker

Docker doesn't have automatic updates.  You can use
[What's UP Docker](https://linuxiac.com/how-to-keep-containers-up-to-date-with-whats-up-docker-wud/)
or
[Watchtower](https://linuxiac.com/watchtower-automatically-update-docker-container-images/)
to do this.

Manually the process looks like this:

```bash
docker pull myimage:latest
docker stop mycontainer
docker rm mycontainer
docker run -d --name mycontainer myimage:latest

```

# Pinning versions

I personally dislike using `latest` tag and pin a specific version tag.  I use this
[script](https://github.com/alejandroliu/0ink.net/tree/main/snippets/2026/container_check.sh)
to check for version changes.  Example usage:

```bash
sh container_check.sh -e '^\d+\.\d+\.\d+$' jellyfin/jellyfin:10.11.6
sh container_check.sh -e '^\d+\.\d+\.\d+$' nginx:1,25.3  -e '^v\d+' ghcr.io/tortugalabs/mylldap:v0.6.2-2026.02

```

This will show matching tags that are newer than your current tag.


Then you can use [runlike](https://pypi.org/project/runlike/) (a python PIP package)
to re-create the `docker run` command.

Podman is easier in that regard.  You can get the run command with:

```bash
podman inspect <image name> | jq .[0].Config.CreateCommand

```

Alternatively, run the container via a YAML file:

1. Generate a K8s YAML file:
   ```bash
   podman generate kube <container> > container.yaml

   ```
2. modify the YAML file, maybe update the image name.
3. Remove the container.
4. Re-create container:
   ```bash
   podman play kube container.yaml

   ```


