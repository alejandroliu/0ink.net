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

This article describes my personal <code>git</code> Workflow.

<h2>Start working on a Topic Branch</h2>

This when we are implementing a new feature. Assumes that you have a working git repo.

<pre><code>git checkout -b "topic" dev
git push -u origin "topic"
</code></pre>

From a different computer, you may want to work on an existing work branch.

<pre><code>git fetch origin
git checkout --track origin/topic
</code></pre>

<h2>Keep Topic Branch current</h2>

While developing a topic we may want to bring any changes done to the dev/integration test...

<pre><code>git checkout topic
git merge dev
</code></pre>

<h2>Merge a Topic Branch</h2>

Once all the development and testing for a topic is done...

<pre><code>git checkout dev
git pull
# switch to the dev (integration) branch
git merge --no-ff topic
# The --no-ff makes this a single commit.
# ... Update any changelogs and commit them...
git push
</code></pre>

<h2>Start working on a HotFix</h2>

This when we want to fix a prod release bug. Assumes that you have a working git repo.

<pre><code>git checkout -b "topic" master
git push -u origin "topic"
</code></pre>

From a different computer, you may want to work on an existing work branch.

<pre><code>git fetch origin
git checkout --track origin/topic
</code></pre>

<h2>Keep HotFix Branch current</h2>

While developing a topic we may want to bring any changes done to the dev/integration test...

<pre><code>git checkout topic
git merge master
</code></pre>

<h2>Merge a HotFix Branch</h2>

Once all the development and testing for a topic is done...

<pre><code>git checkout master
git pull
# switch to the dev (integration) branch
git merge --no-ff topic&lt;/p&gt;
# The --no-ff makes this a single comit.
# ... update any changelogs and commit them ...
git push
git checkout dev
# We also want to add changes to dev...
git merge --no-ff topic
</code></pre>

.. On another system....

<pre><code>git remote prune origin
git branch --delete topic
</code></pre>

<h2>Finish working on a HotFix or Topic Branch</h2>

If really done, or if you want to abort this...

<pre><code>git branch -d topic
git push origin dev|master
# Use dev or master depending on being a topic branch or a hot
# fix branch respectively
git push origin :topic
# Delete the remote branch... Or ...
git push origin --delete topic
</code></pre>

<h2>Create a New Release</h2>

We are ready for a new release...

<pre><code>git checkout dev
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
</code></pre>

<h2>Setup New Project</h2>

For setting up a new project.

<pre><code>mkdir project
cd project
# ... create files ...
git init
git add .
git commit -m"Initial commit"
git tag -a "0.0initial" -m "Initial commit"
git checkout -b "dev" "master"
git tag -a "0.0pre" -m "Development branch"
git push origin --tags</code></pre>

This sets up a local repo with two branches and some descriptive tags. The "master" branch for release code and the "dev" branch for development and integration.

We now need to configure it on the remote repository.

<pre><code>git checkout master
git remote add origin "Remote repo URL"
git push origin master
git checkout dev
git push -u origin dev
git push origin --tags
</code></pre>

<h2>Setup to work on an existing project</h2>

Setup clone:

<pre><code>git clone "Remote repo URL"
git push origin master
</code></pre>
