---
title: My git release script
tags: directory, remote, scripts
---

I always had issues remembering how to create releases.
So in order to standardise things, I wrote this script:

- [ghrelease](https://github.com/TortugaLabs/my-gh-tools/blob/main/ghrelease.sh)

So whenever I am ready to release I would then just issue
the command:

```bash
./ghrelease vX.Y.Z
```

# Pre-requisistes:

You obviously need `git`.  But also you would need
[github-cli](https://github.com/cli/cli).

Your repository must also be *clean*, without any
pending commits.

You must be on the *default* branch (usually `main` or
`master`), unless doing a **pre-release**.

Optionally, you may have a `wfscripts/checks` directory
containing checking scripts.

# What happens on release

1. remote `--tags` will be synchronised with local tags.
2. if a tag of the same name already exists then, release
   will be stopped.
3. check if we are on the `default` branch (unless pre-release)
4. check if there are any uncomitted changes.
5. If available, `wfscripts/checks` is run using `run-parts`
6. Will create release notes based on log entries since the
   last release (previous annotated tagged commit)
7. `VERSION` or `version.h` is updated and comitted.
8. A new annotated tag is created.
9. Commits and tags are push to remote (origin).
10. Release is created using `github-cli`.

# Pre-releases

You can create pre-releases.  These do not have to be on the
*default* branch.  To do this use the `--rc` (Release candidate)
option:

```bash
./ghrelease vX.Y.Z-rcN
```

This will create a release in `github` but tag it as **pre-release**.

After release, you may delete all pre-release candidates:

```bash
./ghrelease --purge
```

