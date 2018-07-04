---
ID: "289"
post_author: "2"
post_date: "2013-05-23 12:34:41"
post_date_gmt: "2013-05-23 12:34:41"
post_title: Git recipes
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: git-recipes
to_ping: ""
pinged: ""
post_modified: "2017-07-02 13:03:50"
post_modified_gmt: "2017-07-02 13:03:50"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=289
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Git recipes

---

<h1>Rewriting history</h1>

<h2>Rolling back the last commit</h2>

if nobody has pulled your remote repo yet, you can change your branch HEAD and force push it to said remote repo:

<pre><code>git reset --hard HEAD^
git push -f
</code></pre>

<h1>Restoring changes</h1>

So in the event that you want to go back to a previous version of a file. First you must identify the version using:

<pre><code>git log $file
</code></pre>

Once you know which commit to go to, do:

<pre><code>git checkout $hash $file
</code></pre>

Then

<pre><code>git commit $file
</code></pre>

<h1>User friendly version ids</h1>

Creating version ids Use:

<pre><code> git describe
</code></pre>

Gives:

<pre><code> $tag-$commit_count-$hash
</code></pre>

However for this to work, you need to have a good tag set and a good tag naming convention.

<h1>Branches</h1>

Main branch names:

<ul>
<li>master - The main branch. Source code of HEAD always reflects production-ready status.</li>
<li>develop or dev - Main dev branch. HEAD always reflects state with the latest development changes for the next release. This can sometimes be called the "integration branch" and used to generate automatic nightly builds.</li>
</ul>

Also a variety of supporting branches to aid parallel development between team members, ease tracking of features, prepare for production releases and to assist in quickly fixing live production problems. Unlike the main branches, these branches always have a limited life time, since they will be removed eventually. Creating a new branch:

<pre><code> git checkout -b new_branch develop
 # Creates a branch called "new_branch" from "develop" and switches to it
  git push -u origin new_branch
  # Pushes "new_branch" to the remote repo
</code></pre>

Listing branches

<pre><code> git branch      # List all local branches
 git branch -a  # List local and remote branches    
</code></pre>

Merging branches

<pre><code> git checkout dev
 # Switches to branch that will receive the commits...
 git merge --no-ff "feature_branch"
 # makes the a single commit (instead of replaying all the commits from the feature branch)
</code></pre>

Deleting branches

<pre><code>git branch -d branch_name    # Only local branches
git push origin --delete branch_name # Remote branch
git push origin :branch_name # Old format for deleting... prefix with ":"
</code></pre>

Clean-up delete branches in remote repo from local repo...

<pre><code>git branch --delete branch
git remote prune origin
</code></pre>

<h1>Tagging</h1>

<h2>Creating tags</h2>

Tag releases with

<pre><code>git tag -a $tagname -m "$descr"
</code></pre>

This creates an annotated tag that has full meta data content and it is favored by Git describe.

<h2>Temporary snapshots</h2>

<pre><code>git tag $tagname
</code></pre>

These are lightweight tag that are associated to a specific commit.

<h2>Sharing tags</h2>

By default are not pushed. They need to be exported with:

<pre><code>git push origin $tagname
</code></pre>

or

<pre><code>git push origin --tags
</code></pre>

<h2>To pull tags (if there aren't any)</h2>

<pre><code>git fetch --tags
</code></pre>

<h2>Deleting tags</h2>

<pre><code>git tag -d $tagname    # Local tags
git push --delete origin $tagname # Remote tags
git push origin :refs/tags/$tagname   # Remote tags (OLD VERSION)

</code></pre>

<h2>Rename a tag:</h2>

<pre><code>git tag new old
git tag -d old
git push origin :refs/tags/old
</code></pre>

<h1>Setting up GIT</h1>

<pre><code>git config --global user.name "user"
git config --global user.email "email"
</code></pre>

Other settings:

<pre><code>[http]
  sslVerify = false
  proxy = http://10.47.142.30:8080/
[user]
  email = alejandro_liu@hotmail.com
  name = alex
</code></pre>

<h2>Using ~/.netrc for persistent authentication</h2>

Create a file called <code>.netrc</code> in your home directory.  Make sure you sets permissions <code>600</code> so
that it is only readable by user.

With Windows, create a file <code>_netrc</code> in your home directory.  You may need to define a %HOME%
environment variable.  In Windows 7 you can use:

<pre><code>setx HOME %USERPROFILE%
</code></pre>

or

<pre><code>set HOME=%HOMEDRIVE%%HOMEPATH%
</code></pre>

The contents of <code>.netrc</code> (or <code>_netrc</code>) are as follows:

<pre><code>|machine $system
|   login $user
|   password $pwd
|machine $system
|   login $user
|   password $pwd
</code></pre>

<h1>Creating new repositories</h1>

<pre><code>mkdir ~/hello-world
cd ~/hello-world
git init
# Creates an empty repository in ~/hello-world
touch file
git add file
git commit -m 'first commit'
# Creates a new file and commits locally
git remote add origin 'https://$user:$passwd@github.com/$user/hello-world.git
# Creates a remote name for push/pull
git push origin master
# Send commits to remote
</code></pre>

Creating a bare repo:

<pre><code>mkdir templ
cd templ
echo "Initial commit" &amp;gt; README.md
git add README.md
git commit -m"Initial commit"
git clone --bare . 
</code></pre>

<h1>Vendor Branches</h1>

Set-up

<pre><code>unzip wordpress-2.3.zip
cd wordpress 
# Note, unzip creates this directory...
git init
git add .
git commit -m 'Import wordpress 2.3'
git tag v2.3
git branch upstream
# Create the upstream branch used to track new vendor releases
</code></pre>

When a new release comes out:

<pre><code>cd wordpress
git checkout upstream
rm -r *
# Delete all files in the main directory but doesn't touch dot files (like .git)
(cd .. &amp;amp;&amp;amp; unzip wordpress-2.3.1.zip)
git add .
git commit -a -m 'Import wordpress 2.3.1'
git tag v2.3.1
git checkout master
git merge upstream
</code></pre>

A variation of vendor branches is to sync with an upstream fork in github.  Read this guide on how to do that: <a href="https://help.github.com/articles/syncing-a-fork/">Syncing a fork on github</a>

<h1>GIT through patches</h1>

Creating a patch:

<pre><code> ... prepare a new branch to keep work separate ...
 git checkout -b mybranch
 ... do work ...
 git commit -a
 .. create the patch from branch "master"...
 git format-patch master --stdout &amp;gt; file.patch
</code></pre>

To apply patch..

<pre><code> ... show what the patch file will do ...
 git apply --stat file.patch
 .. displays issues the patch might cause...
 git apply --check file.patch
 .. apply with am (so you can sign-off)
 git am --signoff &amp;lt; file.patch
</code></pre>

<h1>Maintenance</h1>

<pre><code>git fsck
git gc --prune=now     # Clean-up
git remote prune origin # Clean-up stale references to deleted remote objects
</code></pre>

<h1>Submodules</h1>

Add submodules to a project:

<pre><code>git submodule add $repo_url $dir
</code></pre>

Clone a project with submodules:

<pre><code>git clone $repo_url
cd $repo
git submodule init
git submodule update
</code></pre>

Or in a single command (Git &gt;1.6.5):

<pre><code>git clone --recursive $repo_url
</code></pre>

For already cloned (Git &gt;1.6.5):

<pre><code>git clone $repo_url
cd $repo
git submodule update --init --recursive
</code></pre>

To keep a submodule up-to-date:

<pre><code>git pull
git submodule update
</code></pre>

Remove sub-modules:

<pre><code>git submodule deinit $submodule
git rm $submodule # No trailing slash!
</code></pre>
