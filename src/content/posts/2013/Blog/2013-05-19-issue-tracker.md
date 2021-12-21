---
ID: "160"
post_author: "2"
post_date: "2013-05-19 07:33:01"
post_date_gmt: "2013-05-19 07:33:01"
post_title: Issue Tracker
post_excerpt: ""
post_status: private
comment_status: open
ping_status: closed
post_password: ""
post_name: issue-tracker
to_ping: ""
pinged: ""
post_modified: "2013-05-19 07:33:01"
post_modified_gmt: "2013-05-19 07:33:01"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=119
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Issue Tracker
date: 2013-05-19
---

*   Use DVCS as backend (GIT)
*   Output html
*   markdown
*   Prefer perl/python
*   Mostly RO so to avoid merge conflicts.

## DITZ + git integration

Adding Markdown

*   `lib/html.rb` contains the functions that generate HTML
*   *.rhtml contain templates and call functions in `lib/html.rb` to generate (and format) output.

Note, if working with `github`, refer to [http://github.github.com/github-flavored-markdown/](http://github.github.com/github-flavored-markdown/) Using a markdown library:

*   [http://maruku.rubyforge.org/usage.html](http://maruku.rubyforge.org/usage.html)  
    Pure Ruby
*   [http://kramdown.rubyforge.org/](http://kramdown.rubyforge.org/)  
    Pure Ruby (fast?)
*   [https://github.com/rtomayko/rdiscount](https://github.com/rtomayko/rdiscount)  
    C library
*   [http://ruby.morphball.net/bluefeather/index_en.html](http://ruby.morphball.net/bluefeather/index_en.html)  
    Pure Ruby?

Arch has: redcarpet, rdiscount, maruku, ruby-markdown, github-markdown

# GIT INTEGRATION

## Simple hooks

### ~/.ditz/hooks/after_add.rb:

```
Ditz::HookManager.on :after_add do |project, config, issues|
  issues.each do |issue|
    `git add #{issue.pathname}`
  end
end

```

### ~/.ditz/hooks/after_delete.rb:

```
Ditz::HookManager.on :after_delete do |project, config, issues|
  issues.each do |issue|
    `git rm #{issue.pathname}`
  end
end

```

## GIT Extensions:

[https://github.com/ihrke/git-ditz](https://github.com/ihrke/git-ditz) \-
Adds a "ditz" subcommand to git. See README on how it installs.

## DITZ PLUGINS:

### git-sync

This plugin is useful for when you want synchronized, non-distributed issue  
coordination with other developers, and you're using git. It allows you to  
synchronize issue updates with other developers by using the 'ditz sync`  
command, which does all the git work of sending and receiving issue change  
for you. However, you have to set things up in a very specific way for this  
to work:

1.  Your ditz state must be on a separate branch. I recommend calling it  
    `bugs`. Create this branch, do a ditz init, and push it to the remote  
    repo. (This means you won't be able to mingle issue change and code  
    change in the same commits. If you care.)
2.  Make a checkout of the bugs branch in a separate directory, but NOT in  
    your code checkout. If you're developing in a directory called "project",  
    I recommend making a ../project-bugs/ directory, cloning the repo there  
    as well, and keeping that directory checked out to the 'bugs' branch.  
    (There are various complicated things you can do to make that directory  
    share git objects with your code directory, but I wouldn't bother unless  
    you really care about disk space. Just make it an independent clone.)
3.  Set that directory as your issue-dir in your .ditz-config file in your  
    code checkout directory. (This file should be in .gitignore, btw.)
4.  Run 'ditz reconfigure' and fill in the local branch name, remote  
    branch name, and remote repo for the issue tracking branch.

Once that's set up, 'ditz sync' will change to the bugs checkout dir, bundle  
up any changes you've made to issue status, push them to the remote repo,  
and pull any new changes in too. All ditz commands will read from your bugs  
directory, so you should be able to use ditz without caring about where  
things are anymore. This complicated setup is necessary to avoid accidentally mingling code  
change and issue change. With this setup, issue change is synchronized,  
but how you synchronize code is still up to you. Usage:

1.  read all the above text very carefully
2.  add a line "- git-sync" to the .ditz-plugins file in the project  
    root
3.  run 'ditz reconfigure' and answer its questions
4.  run `ditz sync` with abandon

### git ditz plugin

This plugin allows issues to be associated with git commits and git  
branches. Git commits can be easily tagged with a ditz issue with the 'ditz  
commit' command, and both 'ditz show' and the ditz HTML output will then  
contain a list of associated commits for each issue. Issues can also be
assigned a single git feature branch. In this case, all  
commits on that branch will listed as commits for that issue. This  
particular feature is fairly rudimentary, however---|it assumes the reference  
point is the 'master' branch, and once the feature branch is merged back  
into master, the list of commits disappears. Two configuration variables are
added, which, when specified, are used to  
construct HTML links for the git commit id and branch names in the generated  
HTML output. Commands added:

*   ditz set-branch: set the git branch of an issue
*   ditz commit: run git-commit, and insert the issue id into the commit  
    message.

Usage:

1.  add a line "- git" to the .ditz-plugins file in the project root
2.  run ditz reconfigure, and enter the URL prefixes, if any, from  
    which to create commit and branch links.
3.  use 'ditz commit' with abandon.

### COLLABORATION PLUGINS

#### issue-claiming

This plugin allows people to claim issues. This is useful for avoiding  
duplication of work---|you can check to see if someone's claimed an  
issue before starting to work on it, and you can let people know what  
you're working on. Commands added:

*   ditz claim: claim an issue for yourself or a dev specified in project.yaml
*   ditz unclaim: unclaim a claimed issue
*   ditz mine: show all issues claimed by you
*   ditz claimed: show all claimed issues, by developer
*   ditz unclaimed: show all unclaimed issues

Usage:

1.  add a line "- issue-claiming" to the .ditz-plugins file in the project  
    root
2.  (optional:) add a 'devs' key to project.yaml, e.g:

#### issue labeling

This plugin allows label issues. This can replace the issue component  
and/or issue types (bug,feature,task), by providing a more flexible  
to organize your issues. Commands added:

*   ditz new_label \[label\]: create a new label for the project
*   ditz label : label an issue with some labels
*   ditz unlabel \[labels\]: remove some label(s) of an issue
*   ditz labeled \[release\]: show all issues with these labels

Usage:

1.  add a line "- issue-labeling" to the .ditz-plugins file in the project  
    root
2.  use the above commands to abandon

TODO:

*   extend the HTML view to have per-labels listings
*   allow for more compact way to type them (completion, prefixes...)

#### issue priority

This plugin allows issues to have priorities. Priorities are numbers  
P1-P5 where P1 is the highest priority and P5 is the lowest. Internally  
the priorities are sorted lexicographically. Commands added:

*   ditz set-priority : Set the priority of an issue

Usage:

1.  add a line "- issue-priority" to the .ditz-plugins file in the project  
    root
2.  use the above commands to abandon
