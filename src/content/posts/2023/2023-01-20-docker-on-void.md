---
title: Docker on Void
date: "2023-08-27"
author: alex
tags: login, sudo
---
This is a quick recipe to run Docker on void:

- Make sure your system is up-to-date:
  - `sudo xbps-install -Syu`
- Install docker executables:
  - `sudo xbps-install -S docker`
  - Additional recommended packaged: `docker-compose`, `docker-buildx`.
- Check if docker was installed properly:
  - `docker --version`
- Enable services:
  - `sudo ln -s /etc/sv/containerd /var/service`
  - `sudo ln -s /etc/sv/docker /var/service`
- Add your user to the `docker` group:
  - `sudo usermod -a -G docker $(whoami)`

You can start using docker.  You may need to logout and login again for the group
membership to be updated.

Here is a [beginners tutorial](https://docker-curriculum.com/)


