---
title: Using the Github Container Registry
date: "2025-05-04"
author: alex
tags: github, feature, settings, password, configuration, storage, git, software
---
[toc]
***
![ghcr]({static}/images/2025/ghcr/ghcr.png)

The GitHub Container Registry (GHCR) allows you to host and manage Docker container images in
your personal or organisation account on GitHub. One of the benefits is that permissions can be
defined for the Docker image, independent of any repository. Thus, your repository could be private
and your Docker image public.

This feature is part of Github's Packages feature.  To manage your images you need to go to your
personal or organization's page and click on the `Packages` tab.

By default, packages are "Private".  You can change this default by going to your account or org's
settings page, click on the "Packages" option on the side bar.  Under "Packages permissions" ->
"Package creation", you can change the default visibility.

In general, you can have a Github repo containing the source for a container image, and
through the use of Github Actions, you can automatically publish the container to the
GHCR.  From then on, you can pull the container image using docker engine.

To enable this you need to create a `.github/workflows/docker-image.yml` file with the contents:

![workflow]({static}/images/2025/ghcr/workflow.png)


# Initialization

```yaml
name: Docker Image CI

on:
  workflow_dispatch:
  push:
    branches: [ "prerel", "prerel-*" ]
    tags: [ "*" ]
  pull_request:
    branches: [ "main" ]
```

These control events on when to run the workflow.  See [Events that trigger workflows][gh-events].

For rolling releases I would use:

```yaml
on:
  workflow_dispatch:
  push:
    branches: [ "main", "prerel", "prerel-*", "bugfix*" ]
  schedule:
  # Run every 8th of the month
  - cron: "0 2 8 * *"

```

# Basic env variables

```yaml

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

```
Declares some environmental variables.  Here we are indicating that we will be using
GHCR.  Also, we are using the repository name (owner/repo) for the image name.  Be careful
that the IMAGE_NAME should be all lowercase.

# Job declaration

```yaml
jobs:

  build:

    runs-on: ubuntu-latest

    permissions:
      contents: read
      packages: write
      attestations: write
      id-token: write
```

This starts the actual jobs to run.  The `permissions` block is important as these
are needed to configure the automatic `GITHUB_TOKEN`.  See 
[Controlling permissions for GITHUB_TOKEN][ghtoken] for details.


# Steps

```yaml
    steps:
```

Workflow requires the following steps:

## Run-time additional env variables


```yaml
    - name: Additional environment
      run: |
        (
          echo "IMAGE_NAME=$(echo "${{ env.IMAGE_NAME }}" | tr A-Z a-z)"
          echo "PKG_OWNER=$(echo "${{ env.IMAGE_NAME}}" | cut -d/ -f1)"
          echo "PKG_NAME=$(basename "${{ env.IMAGE_NAME}}")"
          echo "BUILD_DATE=$(date +'%Y%m%d')"
        ) >> $GITHUB_ENV
```
This makes sure that the `env.IMAGE_NAME` is all lowercase.  This is a 
docker client limitation.  It also splits the image name into 
`env.PKG_OWNER` and `env.PKG_NAME`.  The `env.PKG_NAME` is needed later by
the [actions/delete-package-versions][actions/delete-package-versions] action.

## Git source checkout

```yaml
    - name: checkout repository
      uses: actions/checkout@v4
```

This is fairly standard.  Check out our source code.

## Additional configuration

```yaml
    - name: Read additional environment from file
      uses: cosq-network/dotenv-loader@v1.0.2
      with:
        env-file: dotenv
```

Read additional environment variables from a file.  In this
example, `dotenv`.

This is an optional step.  I am using this to define certain variables instead of
hardcoding them into the Dockerfile.

## Log in to GHCR

```yaml
    - name: Log in to the Container registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
```
This steps logs you into the GHCR so you are able to push images.  It uses
[docker/login-action](https://github.com/docker/login-action).  It supports
to many container repositories such as docker hub.  Not just GHCR.

## Container metadata

```yaml
    - name: Extract metadata (tags, labels) for Docker
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=schedule
          type=ref,event=branch
          type=ref,event=tag
          type=ref,event=pr
          type=raw,value={{date 'YYYYMMDD'}}      
```

Gets meta data using [docker/metadata-action][docker/metadata-action]

Tags are generated according to:

| Event               | Ref                           | Docker Tags                |
|---------------------|-------------------------------|----------------------------|
| `pull_request`      | `refs/pull/2/merge`           | `pr-2`                     |
| `push`              | `refs/heads/master`           | `master`                   |
| `push`              | `refs/heads/releases/v1`      | `releases-v1`              |
| `push tag`          | `refs/tags/v1.2.3`            | `v1.2.3`, `latest`         |
| `push tag`          | `refs/tags/v2.0.8-beta.67`    | `v2.0.8-beta.67`, `latest` |
| `workflow_dispatch` | `refs/heads/master`           | `master`                   |

In my example, I also generate a tag based on the date.

Alternatively, for rolling releae I would use:

```yaml
        tags: |
          type=raw,value=latest,enable={{ is_default_branch }}
          type=raw,value={{date 'YYYYMMDD'}}
```
Essentially, we are tagging by date, and the default branch also tags as `latest`.

## Container build and push

```yaml
    - name: Build and push Docker image
      id: push
      uses: docker/build-push-action@v3
      with:
        context: .
        push: true
        tags:  ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        build-args: |
          LIBC=${{ env.LIBC }}
          PYTHON_VERSION=${{ env.PYTHON_VERSION }}
          PYINSTALLER_VERSION=${{ env.PYINSTALLER_VERSION }}
          UPX_VERSION=${{ env.UPX_VERSION }}
```
In this step, we create the image and push it to the GHCR.  It makes use of 
[docker/build-push-action](https://github.com/docker/build-push-action).

1. Tags make use of the output of [docker/metadata-action][docker/metadata-action],
   also make use of some pre-computed values from a previous step.
2. We also pass configuration values to the `Dockerfile` using `build-args`.

## Artifact attestation

```yaml
    - name: Generate artifact attestation
      uses: actions/attest-build-provenance@v2
      with:
        subject-name: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME}}
        subject-digest: ${{ steps.push.outputs.digest }}
        push-to-registry: true

```
Generates signed build provenance attestations for workflow artifacts.

Artifact Attestations allow project maintainers to effortlessly create a tamper-proof,
unforgeable paper trail linking their software to the process which created it.

For more details read
[Introducing Artifact attestations](https://github.blog/news-insights/product-news/introducing-artifact-attestations-now-in-public-beta/).


## Cleaning Container registry

Storage isn't free and registries can often get bloated with unused images. Having a retention
policy to prevent clutter makes sense in most cases.

In GCHR you can use the action [actions/delete-package-versions][actions/delete-package-versions]
to keep things tidy.

Example usage:

```yaml
    - uses: actions/delete-package-versions@v5
      with:
        package-name: "${{ env.PKG_NAME }}"
        package-type: 'container'
        min-versions-to-keep: 9

```
This simply keeps only the last 9 images.

![steps]({static}/images/2025/ghcr/steps.png)

# Using the image

Once the container image is build and published to the GCHR you can run it with a command:

```bash
docker run ghcr.io/pkgowner/imagename:latest
```





  [gh-events]: https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows
  [ghtoken]: https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/controlling-permissions-for-github_token
  [docker/metadata-action]: https://github.com/docker/metadata-action
  [actions/delete-package-versions]: https://github.com/actions/delete-package-versions
