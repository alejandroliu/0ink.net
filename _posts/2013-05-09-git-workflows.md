---
ID: "31"
post_author: "2"
post_date: "2013-05-09 21:45:06"
post_date_gmt: "2013-05-09 21:45:06"
post_title: Git Workflows
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: closed
post_password: ""
post_name: git-workflows
to_ping: ""
pinged: ""
post_modified: "2013-05-09 21:45:06"
post_modified_gmt: "2013-05-09 21:45:06"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=31
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Git Workflows
---

This article describes my personal `git` Workflow.

## Start working on a Topic Branch

This when we are implementing a new feature. Assumes that you have a working git repo.

```
git checkout -b "topic" dev
git push -u origin "topic"

```

From a different computer, you may want to work on an existing work branch.

```
git fetch origin
git checkout --track origin/topic

```

## Keep Topic Branch current

While developing a topic we may want to bring any changes done to the dev/integration test...

```
git checkout topic
git merge dev

```

## Merge a Topic Branch

Once all the development and testing for a topic is done...

```
git checkout dev
git pull
# switch to the dev (integration) branch
git merge --no-ff topic
# The --no-ff makes this a single commit.
# ... Update any changelogs and commit them...
git push

```

## Start working on a HotFix

This when we want to fix a prod release bug. Assumes that you have a working git repo.

```
git checkout -b "topic" master
git push -u origin "topic"

```

From a different computer, you may want to work on an existing work branch.

```
git fetch origin
git checkout --track origin/topic

```

## Keep HotFix Branch current

While developing a topic we may want to bring any changes done to the dev/integration test...

```
git checkout topic
git merge master

```

## Merge a HotFix Branch

Once all the development and testing for a topic is done...

```
git checkout master
git pull
# switch to the dev (integration) branch
git merge --no-ff topic</p>
# The --no-ff makes this a single comit.
# ... update any changelogs and commit them ...
git push
git checkout dev
# We also want to add changes to dev...
git merge --no-ff topic

```

.. On another system....

```
git remote prune origin
git branch --delete topic

```

## Finish working on a HotFix or Topic Branch

If really done, or if you want to abort this...

```
git branch -d topic
git push origin dev|master
# Use dev or master depending on being a topic branch or a hot
# fix branch respectively
git push origin :topic
# Delete the remote branch... Or ...
git push origin --delete topic

```

## Create a New Release

We are ready for a new release...

```
git checkout dev
git push
git pull
# Make sure that dev is up-to-date in both directions...
git checkout master
git push ; git pull
# Make sure that master is up-to-date
git merge --no-ff dev
# ... fix version number ...
git commit -a -m"preparing release X.Y"
git tag -a X.Yrel -m"Release X.Y"
git push
git checkout dev
git merge --no-ff master
# ... bump version number ...
git commit -a -m"Bump version to X.Y+1"
git tag -a X.Y+1pre -m"New dev cycle for X.Y+1"
git push origin dev
git push origin --tags

```

## Setup New Project

For setting up a new project.

```
mkdir project
cd project
# ... create files ...
git init
git add .
git commit -m"Initial commit"
git tag -a "0.0initial" -m "Initial commit"
git checkout -b "dev" "master"
git tag -a "0.0pre" -m "Development branch"
git push origin --tags
```

This sets up a local repo with two branches and some descriptive tags.
The "master" branch for release code and the "dev" branch for
development and integration. We now need to configure it on the remote repository.

```
git checkout master
git remote add origin "Remote repo URL"
git push origin master
git checkout dev
git push -u origin dev
git push origin --tags

```

## Setup to work on an existing project

Setup clone:

```
git clone "Remote repo URL"
git push origin master

```
