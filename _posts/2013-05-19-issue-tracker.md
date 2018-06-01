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
...
---

<ul>
<li>Use DVCS as backend (GIT)</li>
<li>Output html</li>
<li>markdown</li>
<li>Prefer perl/python</li>
<li>Mostly RO so to avoid merge conflicts.</li>
</ul>

<h2>DITZ + git integration</h2>

Adding Markdown

<ul>
<li><code>lib/html.rb</code> contains the functions that generate HTML</li>
<li>*.rhtml contain templates and call functions in <code>lib/html.rb</code> to generate (and format) output.</li>
</ul>

Note, if working with <code>github</code>, refer to <a href="http://github.github.com/github-flavored-markdown/">http://github.github.com/github-flavored-markdown/</a>

Using a markdown library:

<ul>
<li><a href="http://maruku.rubyforge.org/usage.html">http://maruku.rubyforge.org/usage.html</a><br />
Pure Ruby</li>
<li><a href="http://kramdown.rubyforge.org/">http://kramdown.rubyforge.org/</a><br />
Pure Ruby (fast?)</li>
<li><a href="https://github.com/rtomayko/rdiscount">https://github.com/rtomayko/rdiscount</a><br />
C library</li>
<li><a href="http://ruby.morphball.net/bluefeather/index_en.html">http://ruby.morphball.net/bluefeather/index_en.html</a><br />
Pure Ruby?</li>
</ul>

Arch has: redcarpet, rdiscount, maruku, ruby-markdown, github-markdown

<h1>GIT INTEGRATION</h1>

<h2>Simple hooks</h2>

<h3>~/.ditz/hooks/after_add.rb:</h3>

<pre><code>Ditz::HookManager.on :after_add do |project, config, issues|
  issues.each do |issue|
    `git add #{issue.pathname}`
  end
end
</code></pre>

<h3>~/.ditz/hooks/after_delete.rb:</h3>

<pre><code>Ditz::HookManager.on :after_delete do |project, config, issues|
  issues.each do |issue|
    `git rm #{issue.pathname}`
  end
end
</code></pre>

<h2>GIT Extensions:</h2>

<a href="https://github.com/ihrke/git-ditz">https://github.com/ihrke/git-ditz</a> - Adds a "ditz" subcommand to git. See README on how it installs.

<h2>DITZ PLUGINS:</h2>

<h3>git-sync</h3>

This plugin is useful for when you want synchronized, non-distributed issue<br />
coordination with other developers, and you're using git. It allows you to<br />
synchronize issue updates with other developers by using the 'ditz sync`<br />
command, which does all the git work of sending and receiving issue change<br />
for you. However, you have to set things up in a very specific way for this<br />
to work:

<ol>
<li>Your ditz state must be on a separate branch. I recommend calling it<br />
<code>bugs</code>. Create this branch, do a ditz init, and push it to the remote<br />
repo. (This means you won't be able to mingle issue change and code<br />
change in the same commits. If you care.)</li>
<li>Make a checkout of the bugs branch in a separate directory, but NOT in<br />
your code checkout. If you're developing in a directory called "project",<br />
I recommend making a ../project-bugs/ directory, cloning the repo there<br />
as well, and keeping that directory checked out to the 'bugs' branch.<br />
(There are various complicated things you can do to make that directory<br />
share git objects with your code directory, but I wouldn't bother unless<br />
you really care about disk space. Just make it an independent clone.)</li>
<li>Set that directory as your issue-dir in your .ditz-config file in your<br />
code checkout directory. (This file should be in .gitignore, btw.)</li>
<li>Run 'ditz reconfigure' and fill in the local branch name, remote<br />
branch name, and remote repo for the issue tracking branch.</li>
</ol>

Once that's set up, 'ditz sync' will change to the bugs checkout dir, bundle<br />
up any changes you've made to issue status, push them to the remote repo,<br />
and pull any new changes in too. All ditz commands will read from your bugs<br />
directory, so you should be able to use ditz without caring about where<br />
things are anymore.

This complicated setup is necessary to avoid accidentally mingling code<br />
change and issue change. With this setup, issue change is synchronized,<br />
but how you synchronize code is still up to you.

Usage:

<ol>
<li>read all the above text very carefully</li>
<li>add a line "- git-sync" to the .ditz-plugins file in the project<br />
root</li>
<li>run 'ditz reconfigure' and answer its questions</li>
<li>run <code>ditz sync</code> with abandon</li>
</ol>

<h3>git ditz plugin</h3>

This plugin allows issues to be associated with git commits and git<br />
branches. Git commits can be easily tagged with a ditz issue with the 'ditz<br />
commit' command, and both 'ditz show' and the ditz HTML output will then<br />
contain a list of associated commits for each issue.

Issues can also be assigned a single git feature branch. In this case, all<br />
commits on that branch will listed as commits for that issue. This<br />
particular feature is fairly rudimentary, however---|it assumes the reference<br />
point is the 'master' branch, and once the feature branch is merged back<br />
into master, the list of commits disappears.

Two configuration variables are added, which, when specified, are used to<br />
construct HTML links for the git commit id and branch names in the generated<br />
HTML output.

Commands added:

<ul>
<li>ditz set-branch: set the git branch of an issue</li>
<li>ditz commit: run git-commit, and insert the issue id into the commit<br />
message.</li>
</ul>

Usage:

<ol>
<li>add a line "- git" to the .ditz-plugins file in the project root</li>
<li>run ditz reconfigure, and enter the URL prefixes, if any, from<br />
which to create commit and branch links.</li>
<li>use 'ditz commit' with abandon.</li>
</ol>

<h3>COLLABORATION PLUGINS</h3>

<h4>issue-claiming</h4>

This plugin allows people to claim issues. This is useful for avoiding<br />
duplication of work---|you can check to see if someone's claimed an<br />
issue before starting to work on it, and you can let people know what<br />
you're working on.

Commands added:

<ul>
<li>ditz claim: claim an issue for yourself or a dev specified in project.yaml</li>
<li>ditz unclaim: unclaim a claimed issue</li>
<li>ditz mine: show all issues claimed by you</li>
<li>ditz claimed: show all claimed issues, by developer</li>
<li>ditz unclaimed: show all unclaimed issues</li>
</ul>

Usage:

<ol>
<li>add a line "- issue-claiming" to the .ditz-plugins file in the project<br />
root</li>
<li>(optional:) add a 'devs' key to project.yaml, e.g:</li>
</ol>

<h4>issue labeling</h4>

This plugin allows label issues. This can replace the issue component<br />
and/or issue types (bug,feature,task), by providing a more flexible<br />
to organize your issues.

Commands added:

<ul>
<li>ditz new_label [label]: create a new label for the project</li>
<li>ditz label  : label an issue with some labels</li>
<li>ditz unlabel  [labels]: remove some label(s) of an issue</li>
<li>ditz labeled  [release]: show all issues with these labels</li>
</ul>

Usage:

<ol>
<li>add a line "- issue-labeling" to the .ditz-plugins file in the project<br />
root</li>
<li>use the above commands to abandon</li>
</ol>

TODO:

<ul>
<li>extend the HTML view to have per-labels listings</li>
<li>allow for more compact way to type them (completion, prefixes...)</li>
</ul>

<h4>issue priority</h4>

This plugin allows issues to have priorities. Priorities are numbers<br />
P1-P5 where P1 is the highest priority and P5 is the lowest. Internally<br />
the priorities are sorted lexicographically.

Commands added:

<ul>
<li>ditz set-priority  : Set the priority of an issue</li>
</ul>

Usage:

<ol>
<li>add a line "- issue-priority" to the .ditz-plugins file in the project<br />
root</li>
<li>use the above commands to abandon</li>
</ol>

