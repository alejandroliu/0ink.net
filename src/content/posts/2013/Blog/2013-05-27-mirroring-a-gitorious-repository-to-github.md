---
ID: "342"
post_author: "2"
post_date: "2013-05-27 10:06:39"
post_date_gmt: "2013-05-27 10:06:39"
post_title: Mirroring a Gitorious repository to GitHub
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: mirroring-a-gitorious-repository-to-github
to_ping: ""
pinged: ""
post_modified: "2013-05-27 10:06:39"
post_modified_gmt: "2013-05-27 10:06:39"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=342
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Mirroring a Gitorious repository to GitHub
date: 2013-05-27
---

There is nothing special with [GitHub](http://github.com/) and
[Gitorious](http://gitorious.com/) here. This technique would work
exactly the same the other way around or with other servers.

# In a nutshell

```
# Inital setup
git clone --mirror git://gitorious.org/weasyprint/weasyprint.git weasyprint
GIT_DIR=weasyprint git remote add github git@github.com:SimonSapin/WeasyPrint.git

# In cron
cd /path/to/project && git fetch -q && git push -q --mirror github

```

# How it works

Mirroring with Git is pretty easy: just pull from or push to another
repository. [GitHub](http://github.com/) and
[Gitorious](http://gitorious.com/) allow you to push to them or pull
from them, but you can not make them push to somewhere else. You need
something in the middle. Digging a bit in the man pages tells you that
the magic option is `--mirror`. First, clone your "source" repository:

```
git clone --mirror git://gitorious.org/weasyprint/weasyprint.git weasyprint

```

`--mirror` implies `--bare`. This repository is not for working, you
don't want it to have a working directory. More importantly, `--mirror`
sets up the origin remote so that git fetch will directly fetch into
local branches without doing any merge. It will force the update if
the remote history has diverged from the local one.

```
git fetch

```

Now our local repository is an exact mirror of what we have on
[Gitorious](http://gitorious.com/). Let's push it to [GitHub](http://github.com/):

```
git remote add github git@github.com:SimonSapin/WeasyPrint.git
git push --mirror github

```

The `--mirror` option for git push is similar to that for git clone:
instead of pushing just a branch, it says that all references (branches,
tags, -) should be the same on the remote end as they are here, even if
it means forced updates or removing. Now our
[GitHub](http://gitorious.com/) repository also is a mirror. Let's
update it every hour with cron. The `-q` option says to suppress normal
output but keep error messages, which cron should send you by email if
your server is properly configured.

```
42 *    * * *   cd /path/to/weasyprint && git fetch -q && git push -q --mirror github

```

### Warning: `--mirror` is like `--force`

Both `--mirror` options are kind of like `--force` in that you can
lose data if you're not careful. It will make exact mirrors, no question
asked. If you push changes to the mirror's destination, they will be
overwritten/removed on the next update if they are not in the mirror's
source.

Original article by Simon Sapin: [http://exyr.org/2011/git-mirrors/](http://exyr.org/2011/git-mirrors/)
