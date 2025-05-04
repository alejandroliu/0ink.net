---
title: Using the Github Container Registry
date: "2025-05-04"
author: alex
tags: github, feature, settings, password, configuration
---
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


```yaml
name: Docker Image CI

on:
  push:
    branches: [ "prerel", "prerel-*" ]
    tags: [ "*" ]
  pull_request:
    branches: [ "main" ]
```

These control events on when to run the workflow.  See [Events that trigger workflows][gh-events].

```yaml

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

```
Declares some environmental variables.  Here we are indicating that we will be using
GHCR.  Also, we are using the repository name (owner/repo) for the image name.  Be careful
that the IMAGE_NAME should be all lowercase.

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

```yaml
    steps:
```

Workflow requires the following steps:

```yaml
    - name: checkout repository
      uses: actions/checkout@v4
```

This is fairly standard.  Check out our source code.

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


```yaml
    - name: Extract metadata (tags, labels) for Docker
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
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

```yaml
    - name: Add additional ids
      id: myids
      run: |
        echo "${{ steps.meta.outputs.tags }}"
        (
          echo IMAGE_NAME="$(echo '${{ env.IMAGE_NAME }}' | tr A-Z a-z)"
          echo DATE=$(date +'%Y%m%d')
          echo PYTHON_VERSION=3.12.4
          echo PYINSTALLER_VERSION=6.2
          echo UPX_VERSION=4.2.1
        ) >> $GITHUB_OUTPUT
```
This is an optional step.  I am using this to define certain variables instead of
hardcoding them into the Dockerfile.

1. Because in this example, the repository has uppercase characters, IMAGE_NAME is
   converted to all lowercase.
2. I generate a date based on todays date.
3. A numer of settings are defined here.  While in this example, these are
   hardcoded, normally I would read from a file in the repository proper.

```yaml
    - name: Build and push Docker image
      id: push
      uses: docker/build-push-action@v3
      with:
        context: .
        push: true
        tags: |
          ${{ steps.meta.outputs.tags }}
          ${{ env.REGISTRY }}/${{ steps.myids.outputs.IMAGE_NAME }}:${{ steps.myids.outputs.DATE }}
        labels: ${{ steps.meta.outputs.labels }}
        build-args: |
          PYTHON_VERSION=${{ steps.myids.outputs.PYTHON_VERSION }}
          PYINSTALLER_VERSION=${{ steps.myids.outputs.PYINSTALLER_VERSION }}
          UPX_VERSION=${{ steps.myids.outputs.UPX_VERSION }}
```
In this step, we create the image and push it to the GHCR.  It makes use of 
[docker/build-push-action](https://github.com/docker/build-push-action).

1. Tags make use of the output of [docker/metadata-action][docker/metadata-action],
   also make use of some pre-computed values from a previous step.
2. We also pass configuration values to the `Dockerfile` using `build-args`.

```yaml
    - name: Generate artifact attestation
      uses: actions/attest-build-provenance@v2
      with:
        subject-name: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME}}
        subject-digest: ${{ steps.push.outputs.digest }}
        push-to-registry: true

```
Generates signed build provenance attestations for workflow artifacts.

![steps]({static}/images/2025/ghcr/steps.png)


Once the container image is build and published to the GCHR you can run it with a command:

```bash
docker run ghcr.io/pkgowner/imagename 
```




  [gh-events]: https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows
  [ghtoken]: https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/controlling-permissions-for-github_token
  [docker/metadata-action]: https://github.com/docker/metadata-action