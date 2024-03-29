---
title: Docker on Alpine Linux
tags: alpine, boot, installation, linux, service, ubuntu
---

Alpine Linux Quick installation

See [wiki](https://wiki.alpinelinux.org/wiki/Docker)  For Alpine Linux > 3.8

1. Un-comment community repo from `/etc/apk/repositories`
2. apk add docker
3. rc-update add docker boot
4. service docker start

Optional: (docker compose)

```
apk add docker-compose
```

* * *

Note 2021-03-21: When I tested this, the `daemon.json` did not
work!  Your mileage may vary.

* * *

Recommended for user namespace isolation (not sure if this works)

Also is good to use data mode (persistent /var) as most docker data is stored there.

```
adduser -SDHs /sbin/nologin dockremap
addgroup -S dockremap
echo dockremap:100000:65535 | tee /etc/subuid
echo dockremap:100000:65535 | tee /etc/subgid
```

In `/etc/docker/daemon.json`:

```
{
        "userns-remap": "dockremap"
}
```
For more info [docker docs](https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file)

## Test docker:

1. docker version
2. docker info
3. docker run hello-world
4. docker image ls
5. docker container ls
6. docker container ls --all
6. docker container ls --aq

## Mounting NFS

From docker 17.06, you can mount NFS shares to the container directly when you run it, without the need of extra capabilities

```
docker run --mount 'type=volume,src=VOL_NAME,volume-driver=local,dst=/LOCAL-MNT,volume-opt=type=nfs,volume-opt=device=:/NFS-SHARE,"volume-opt=o=addr=NFS-SERVER,vers=4,hard,timeo=600,rsize=1048576,wsize=1048576,retrans=2"' -d -it --name mycontainer ubuntu
```

## Useful options for docker

- `docker run -d` : Run as a daemon (runs in the background).
- NFS mounting (pre 17.06)
    - `you@host > mount server:/dir /path/to/mount/point`
    - `you@host > docker run -v /path/to/mount/point:/path/to/mount/point`
- `docker run -p 4000:80` : Forward port 4000 to 80.
   So host listens on port 4000 and everything is forwarded to port 80 on the container.

## Alpine Linux relocating /var/lib/docker

In the file `/etc/conf.d/docker` you can add additional command line
options in:

`DOCKER_OPTS`

In particular you can use the `-g` option.

See [linuxconfig.org article](https://linuxconfig.org/how-to-move-docker-s-default-var-lib-docker-to-another-directory-on-ubuntu-debian-linux)

## Make your own docker image, quick example

- [Run the app](https://docs.docker.com/get-started/part2/#run-the-app)

## Making changes to an existing image

- `docker run -i -t [--name guest] image_name /bin/bash|/bin/sh`
- ... make changes to it ...
- `docker stop name|container_id`
- `docker commit -m 'change name' -a 'A N Other' container_id image_name
    - container id: `$(docker ps -l -q)`
- `docker rm guest|container_id`

## Better way to create container images:

- [Updating containers](https://serversforhackers.com/c/updating-containers)




## Just use them...

- [docker](https://github.com/maxexcloo/Docker)
- [linuxerver](https://www.linuxserver.io/)


