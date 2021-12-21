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

A collection of small useful recipes for using with `Git`.


Rewriting history
=================

Rolling back the last commit
----------------------------

if nobody has pulled your remote repo yet, you can change your branch HEAD and force push it to said remote repo:

    git reset --hard HEAD^
    git push -f
    

Restoring changes
=================

So in the event that you want to go back to a previous version of a file. First you must identify the version using:

    git log $file
    

Once you know which commit to go to, do:

    git checkout $hash $file
    

Then

    git commit $file
    

User friendly version ids
=========================

Creating version ids Use:

     git describe
    

Gives:

     $tag-$commit_count-$hash
    

However for this to work, you need to have a good tag set and a good tag naming convention.

Branches
========

Main branch names:

*   master - The main branch. Source code of HEAD always reflects production-ready status.
*   develop or dev - Main dev branch. HEAD always reflects state with the latest development changes for the next release. This can sometimes be called the "integration branch" and used to generate automatic nightly builds.

Also a variety of supporting branches to aid parallel development between team members, ease tracking of features, prepare for production releases and to assist in quickly fixing live production problems. Unlike the main branches, these branches always have a limited life time, since they will be removed eventually. Creating a new branch:

     git checkout -b new_branch develop
     # Creates a branch called "new_branch" from "develop" and switches to it
      git push -u origin new_branch
      # Pushes "new_branch" to the remote repo
    

Listing branches

     git branch      # List all local branches
     git branch -a  # List local and remote branches    
    

Merging branches

     git checkout dev
     # Switches to branch that will receive the commits...
     git merge --no-ff "feature_branch"
     # makes the a single commit (instead of replaying all the commits from the feature branch)
    

Deleting branches

    git branch -d branch_name    # Only local branches
    git push origin --delete branch_name # Remote branch
    git push origin :branch_name # Old format for deleting... prefix with ":"
    

Clean-up delete branches in remote repo from local repo...

    git branch --delete branch
    git remote prune origin
    

Tagging
=======

Creating tags
-------------

Tag releases with

    git tag -a $tagname -m "$descr"
    

This creates an annotated tag that has full meta data content and it is favored by Git describe.

Temporary snapshots
-------------------

    git tag $tagname
    

These are lightweight tag that are associated to a specific commit.

Sharing tags
------------

By default are not pushed. They need to be exported with:

    git push origin $tagname
    

or

    git push origin --tags
    

To pull tags (if there aren't any)
----------------------------------

    git fetch --tags
    

Deleting tags
-------------

    git tag -d $tagname    # Local tags
    git push --delete origin $tagname # Remote tags
    git push origin :refs/tags/$tagname   # Remote tags (OLD VERSION)
    
    

Rename a tag:
-------------

    git tag new old
    git tag -d old
    git push origin :refs/tags/old
    

Setting up GIT
==============

    git config --global user.name "user"
    git config --global user.email "email"
    

Other settings:

    [http]
      sslVerify = false
      proxy = http://10.47.142.30:8080/
    [user]
      email = alejandro_liu@hotmail.com
      name = alex
    

Using ~/.netrc for persistent authentication
--------------------------------------------

Create a file called `.netrc` in your home directory. Make sure you sets permissions `600` so that it is only readable by user. With Windows, create a file `_netrc` in your home directory. You may need to define a %HOME% environment variable. In Windows 7 you can use:

    setx HOME %USERPROFILE%
    

or

    set HOME=%HOMEDRIVE%%HOMEPATH%
    

The contents of `.netrc` (or `_netrc`) are as follows:

    |machine $system
    |   login $user
    |   password $pwd
    |machine $system
    |   login $user
    |   password $pwd
    

Creating new repositories
=========================

    mkdir ~/hello-world
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
    

Creating a bare repo:

    mkdir templ
    cd templ
    echo "Initial commit" &gt; README.md
    git add README.md
    git commit -m"Initial commit"
    git clone --bare . 
    

Vendor Branches
===============

Set-up

    unzip wordpress-2.3.zip
    cd wordpress 
    # Note, unzip creates this directory...
    git init
    git add .
    git commit -m 'Import wordpress 2.3'
    git tag v2.3
    git branch upstream
    # Create the upstream branch used to track new vendor releases
    

When a new release comes out:

    cd wordpress
    git checkout upstream
    rm -r *
    # Delete all files in the main directory but doesn't touch dot files (like .git)
    (cd .. &amp;&amp; unzip wordpress-2.3.1.zip)
    git add .
    git commit -a -m 'Import wordpress 2.3.1'
    git tag v2.3.1
    git checkout master
    git merge upstream
    

A variation of vendor branches is to sync with an upstream fork in github. Read this guide on how to do that: [Syncing a fork on github](https://help.github.com/articles/syncing-a-fork/)

GIT through patches
===================

Creating a patch:

     ... prepare a new branch to keep work separate ...
     git checkout -b mybranch
     ... do work ...
     git commit -a
     .. create the patch from branch "master"...
     git format-patch master --stdout &gt; file.patch
    

To apply patch..

     ... show what the patch file will do ...
     git apply --stat file.patch
     .. displays issues the patch might cause...
     git apply --check file.patch
     .. apply with am (so you can sign-off)
     git am --signoff &lt; file.patch
    

Maintenance
===========

    git fsck
    git gc --prune=now     # Clean-up
    git remote prune origin # Clean-up stale references to deleted remote objects
    

Submodules
==========

Add submodules to a project:

    git submodule add $repo_url $dir
    

Clone a project with submodules:

    git clone $repo_url
    cd $repo
    git submodule init
    git submodule update
    

Or in a single command (Git >1.6.5):

    git clone --recursive $repo_url
    

For already cloned (Git >1.6.5):

    git clone $repo_url
    cd $repo
    git submodule update --init --recursive
    

To keep a submodule up-to-date:

    git pull
    git submodule update
    

Remove sub-modules:

    git submodule deinit $submodule
    git rm $submodule # No trailing slash!
