---
title: Looking up docker image tags
tags: alpine, library
---
This recipe is to check the tags defined for a specific Docker image
in [docker.hub][hub].

The basic API is at https://registry.hub.docker.com/v2

So the format is as follows:

**https://registry.hub.docker.com/v2/repositories/**__{namespace}__/__{image}__**/tags/**

Where:

* __namespace__ : usually is the user account posting the image.  For **official** images
  set the __namespace__ to `library`.
* __image__ : Image name.

Examples:

- [Docker Official alpine image](https://hub.docker.com/_/alpine)
  - namespace: library
  - image : alpine
- [photoprism/photoprism](https://hub.docker.com/r/photoprism/photoprism)
  - namespace : photoprism
  - image : photoprism

So, you can then use `curl` and `jq` to access the relevant data.  For example,
to get the tags, last updated time and digest as a tsv:

```bash
curl -s -L $URL | jq -r '(.results[] | select(.tag_status == "active") | [.name, .last_updated
, .digest]) | @tsv'

```


# v1 API

You could also use the v1 API while it is still available:

**https://registry.hub.docker.com/api/content/v1/repositories/public/**__{namespace}__/__{image}__**/tags/**



  [hub]: https://hub.docker.com
  
