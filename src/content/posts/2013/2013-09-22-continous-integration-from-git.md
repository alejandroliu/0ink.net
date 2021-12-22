---
ID: "680"
post_author: "2"
post_date: "2013-09-22 18:49:34"
post_date_gmt: "2013-09-22 18:49:34"
post_title: Continuous Integration from Git
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: continous-integration-from-git
to_ping: ""
pinged: ""
post_modified: "2013-09-22 18:49:34"
post_modified_gmt: "2013-09-22 18:49:34"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=680
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Driving Continuous Integration from Git
date: 2013-09-22
tags: config, configuration, directory, feature, git, information, integration, password, remote, scripts, software, tools
revised: 2021-12-22
---

**Testing, code coverage, style enforcement are all check-in and merge
requirements that can be automated and driven from Git.**

If you're among the rising number of Git users out there, you're in
luck: You can automate pieces of your development workflow with Git
hooks. Hooks are a native Git mechanism for firing off custom scripts
before or after certain operations such as commit, merge, applypatch,
and others. Think of them as henchmen for your Git repo. Pre-operation
hooks act as bouncers, guarding your repo with a velvet rope. And
post-operation hooks are your Man Friday, faithfully carrying out
follow-up tasks on your behalf.

Installing hooks for a Git repository is fairly straightforward, and
[well-documented](http://git-scm.com/book/en/Customizing-Git-Git-Hooks).
In this article, we focus on using Git hooks to augment continuous
integration practices, starting with an example that makes combining
Git and continuous integration (CI) less painful. The code is written
in Ruby. Fortunately, Ruby is a language that highly prizes readability,
so even if you don't know Ruby, you can easily follow along.

# Automate CI Configuration for Git Branches

One of the blessings of Git is how easy it is to branch off and develop
in isolation. This means the master stays releasable, you get the
freedom to experiment, and your teammates aren't derailed if code from
the experimentation proves to be half-baked. One challenge of Git,
however, is how many branches a team ends up with ? scores of active
branches, most of which live for only a few days. Who is going to take
the time to set up continuous integration for all those piddly little
branches? Your henchmen, that's who.

To automatically apply CI to new development branches, you'll use the
"post-receive" hook type. These are server-side hooks, triggered after
pushes to the repository are completed. In such cases, you can use the
post-receive hook to fire off a script that programmatically clones a
master's CI configs and applies them to new branches using the CI
server's exposed API. It might look something like this, when using
the open-source and hugely popular [Jenkins](http://www.jenkins-ci.org/)
CI server:

~~~ruby
#!/usr/bin/env ruby
  
 # Ref update hook for creating new Jenkins job 
 # configurations for newly pushed branches.
 #
 # requires Ruby 1.9.3+ 
  
 require 'yaml'
 require 'net/https'
 require 'uri'
 require 'rexml/document'
 include REXML
  
 # load ci-config.yml from hook directory
 def load_config
     hookDir = File.expand_path File.dirname(__FILE__)
     configPath = hookDir + "/ci-config.yml"
     puts configPath
     raise "No ci-config.yml found." unless File.exists? configPath
     YAML.load_file(configPath)
 end
  
 # Grab the configured Jenkins server
 config = load_config
 raise "ci-config.yml file is incomplete: missing jenkins_server" unless
     config["jenkins_server"]
 server = config["jenkins_server"]
 raise "ci-config.yml file is incomplete: username, password, url and
     default_job are required for jenkins_server" unless
         server['url'] and server['username'] and
         server['password'] and server['default_job']
  
 # iterate through updated refs looking for new branches
 ARGF.readlines.each { |line|
     args = line.split
     oldVal = args[0]
     newVal = args[1]
     ref = args[2]
  
     if /^0{40}$/.match(oldVal) and ref.start_with?("refs/heads/") 
         # new branch!
         # retrieve the jenkins job config
         # TODO only need to do this once!
         uri = URI.parse(
            "#{server['url']}/job/#{server['default_job']}/config.xml")
         req = Net::HTTP::Get.new(uri.to_s)
         req.basic_auth server['username'], server['password']
         http = Net::HTTP.new(uri.host, uri.port)
         http.verify_mode = OpenSSL::SSL::VERIFY_NONE
         http.use_ssl = uri.scheme.eql?("https")
  
         # execute the request
         response = http.start {|http| http.request(req)}
  
         raise "Bad response from jenkins, is your ci-config.yml correct?"
             unless response.is_a? Net::HTTPOK
  
         # parse the config.xml from the response
         doc = Document.new response.body
         doc.root.get_elements(
             "//branches/hudson.plugins.git.BranchSpec/name").each { 
                 # overwrite branch to be our new ref
                 |elem| elem.text = ref 
         }
  
         # create a new request to upload the modified config.xml
         newJob = ""
         doc.write newJob
  
         newJobName = ref["refs/heads/".length..-1].gsub("/", "-")
         uri = URI.parse("#{server['url']}/createItem?name=#{newJobName}")        
         req = Net::HTTP::Post.new(uri.to_s, 
         initheader = {'Content-Type' => 'application/xml'})
  
         req.basic_auth server['username'], server['password']
         req.body = newJob
  
         # upload the new job
         response = http.start {|http| http.request(req)}
         raise "Failed to post new job to jenkins" unless
             response.is_a? Net::HTTPOK
     end
 }
~~~

With this hook in place, you need only push a dev branch to the repo,
and it will automatically be put under test. (It's possible to run CI
builds against branches using a build parameter to represent the
target branch, but that muddles the build history. The cloning approach
provides a clean, clear history.) Applying every last facet of the CI
scheme to branches isn't necessary ? for example, running each and
every branch through the load test gamut might be overkill. But even
if you skip the load and UI tests, and run just unit and API- or
integration-level tests, these are huge wins.

The risk of introducing defects into master is greatly reduced by
testing on the branch before merging. Developers can also work more
efficiently and confidently because of the frequent feedback on
changes (instead of the old merge-then-pray technique). And for teams
who include testing as part of their definition of "done," managers
and scrum master types catch a break. With the Git hook automatically
putting branch code under test, the team's practices and values are
being enforced without the need for nag-mails or raised eyebrows during
stand-up.

# Vet Merges to Master

Two hallmarks of coding craftsmanship are an affinity for automated
tests, and adherence to stylistic rules (such as avoiding empty
try/catch blocks or duplicated code). Despite best intentions, everyone
neglects best practices from time to time. That's where Git hooks come
in. Pre-receive hooks living in the central repository qualify incoming
pushes, making sure they're good enough to get past the velvet rope.
Let's look at three hooks designed to protect master from slip-ups made
on development branches.

# Require Passing Branch Builds

The whole point of working on a development branch is to isolate
yourself and create a space to experiment (read: "break stuff"). So
it's natural to see failing tests on the branch while development is
in progress. When it's time to merge to master, however, things had
better be tidied up. This can be enforced programmatically with a hook
that checks to see whether the incoming push is a merge to master, and
if so, verify that all tests are passing on the branch before
processing the merge.

If you happen to be using Bamboo, you can cleanly fetch test results
for a given commit. If you use Jenkins or its predecessor, [Hudson](http://www.hudson-ci.org/),
you can fetch a set of recent build results then parse through them
to see which builds ran against the commit in question. (This hook,
and those that follow are implemented for the Bamboo CI server, but
they can be implemented in more or less the same way on all CI
servers.)


~~~ruby
#!/usr/bin/env ruby
  
 # Ref update hook for verifying the build status of 
 # a topic branch being merged into 
 # a protected branch (e.g. master) from a Bamboo server.
 #
 # requires Ruby 1.9.3+ 
  
 require_relative 'ci-util'
 require 'json'
  
 # parse args supplied by git: <ref_name> <old_sha> <new_sha>
 ref = simple_branch_name ARGV[0]
 prevCommit = ARGV[1]
 newCommit = ARGV[2]
  
 # test if the updated ref is one we want to enforce green 
 # builds for exit_if_not_protected_ref(ref)
  
 # get the tip of the most recently merged branch
 tip_of_merged_branch = 
    find_newest_non_merge_commit(prevCommit, newCommit)
  
 # parse our Bamboo server config
 bamboo = read_config("bamboo", ["url", "username", "password"])
 
 # query Bamboo for build results
 response = httpGet(
    bamboo, 
    "/rest/api/latest/result/byChangeset/#{tip_of_merged_branch}.json")
 body = JSON.parse(response.body)        
 # tally the results
 failed = successful = in_progress = 0
 body['results']['result'].collect { |result|
     case result['state']
     when "Failed"
       failed += 1
     when "Successful"
       successful += 1
     when "Unknown"
       if result['lifeCycleState'] == "InProgress"
         in_progress += 1
       end
     end
 }
  
 # display a short message describing the build status for 
 #the merged branch and abort if necessary
 if failed > 0
     # at least one red build - block the branch update
     abort "#{shortSha(tip_of_merged_branch)} has #{failed} 
     red #{pluralize(failed, 'build', 'builds')}."
 elsif in_progress > 0
     # at least one incomplete build - block the branch update
     abort "#{shortSha(tip_of_merged_branch)} has #{in_progress}
     #{pluralize(in_progress, 'build', 'builds')} that have not
     completed yet."
 else   
     # all green builds - allow the branch update
     puts "#{shortSha(tip_of_merged_branch)} has #{successful} 
         green #{pluralize(successful, 'build', 'builds')}."
 end
~~~

# Enforce Code Coverage Requirements

Along with successful test runs, you want to make sure that new code
added on development branches is tested as thoroughly as code already
on master. This ensures that the overall test coverage level of the
project doesn't drop when a development branch is merged back in. This,
too, can be checked with Git hooks.

A simple Git hook can verify that coverage on the branch meets the
minimum threshold. To enforce this, a hook can be created to compare
the coverage rate on master with that of the branch, and reject the
merge if the branch's coverage is inferior.

Most CI servers don't expose code coverage data through their remote
APIs. But there's an easy work-around: pulling down the code coverage
report. To do this, the build must be configured to publish the report
as a shared artifact, both on master and on the branch build. (Notice
how automatically cloning build configs for development branches comes
in handy here: set it up for master, and get it on the branch for free!)
Once published, you can get the latest coverage report from master by
a call to the CI server. For branch coverage, you can fetch the
coverage report either from the latest build, or for builds related to
the reference (commit) being merged, as shown here for the code
coverage tool Clover.

~~~ruby
#!/usr/bin/env ruby
  
 # Ref update hook for asserting the code coverage of a 
 # topic branch being merged into a 
 # protected branch (e.g. master) is the same or better
 #
 # requires Ruby 1.9.3+ 
  
 require_relative 'ci-util'
 require 'rexml/document'
  
 include REXML
  
 # Determine the code coverage for a particular commit by 
 # parsing Clover artifacts
 def find_coverage(bamboo, commit)
     # grab the clover.xml artifact from the build. 
     # This (assumes a shared artifact named 
     # 'clover' with 'clover.xml' at the root).
     # Change this for your coverage tool?s report name.
     clover_xml = shared_artifact_for_commit(bamboo, commit,
         bamboo["coverage_key"], "clover/clover.xml")
     doc = Document.new clover_xml
  
     # parse out the project metrics element from the response
     metrics = XPath.first(doc, "coverage/project/metrics")
  
     # Use algorithm similar to Clover 
     # (https://confluence.atlassian.com/x/LoHEB) for 
     # determining coverage percentage
     covered_elements = 
         metrics.attribute("coveredconditionals").value.to_i
     covered_elements += 
         metrics.attribute("coveredmethods").value.to_i
     covered_elements += 
         metrics.attribute("coveredstatements").value.to_i
  
     elements = metrics.attribute("conditionals").value.to_i
     elements += metrics.attribute("methods").value.to_i
     elements += metrics.attribute("statements").value.to_i
  
     coverage = 0
     if (elements > 0)
         coverage = covered_elements / elements
     end
     coverage
 end
  
 # parse args supplied by git: <ref_name> <old_sha> <new_sha>
 ref = simple_branch_name ARGV[0]
 prevCommit = ARGV[1]
 newCommit = ARGV[2]
  
 # test if the updated ref is one we want to enforce 
 # green builds for  exit_if_not_protected_ref(ref)
  
 # get the tip of the most recently merged branch
 tip_of_merged_branch = 
     find_newest_non_merge_commit(prevCommit, newCommit)
  
 # parse our bamboo server config
 bamboo = read_config("bamboo", 
     ["url", "username", "password", "coverage_key"])
  
 # calculate code coverage for the old and new commits
 prev_coverage = find_coverage(bamboo, prevCommit)
 new_coverage = find_coverage(bamboo, tip_of_merged_branch)
  
 # if the coverage has dropped for the new commit, block the update
 if prev_coverage > new_coverage
     abort "Code coverage for #{shortSha(tip_of_merged_branch)} is 
         only #{new_coverage}! #{ref} is currently at #{prev_coverage}." 
 else
     # if the coverage has increased, TFCIT
     puts "Nice work! Code coverage for #{ref} has 
         increased by #{new_coverage - prev_coverage}."
 end
~~~

# Enforce Good Coding Style

Tests are something no self-respecting software project can do without,
but they only tell part of the story. Open source tools such as
[Checkstyle](http://checkstyle.sourceforge.net/) and 
[Findbugs](http://findbugs.sourceforge.net/) scour your codebase and
provide reports on stylistic violations ? anything from duplicated
code to excessively long methods to the use of deprecated methods.
These are hard-won guidelines, and they exist for a reason: Ignoring
them can result in code being harder to understand, harder to maintain,
and more vulnerable to runtime problems.

As with code coverage, each team has a different level of tolerance
for unstylish code. But introducing more style violations is almost
universally agreed-upon as undesirable. In this, Git hooks come to the
rescue. Build artifacts come into play here as well since you can
easily retrieve the violations report. (No CI server we're aware of
exposes static analysis data via remote access API.) So you can create
another pre-receive hook that checks violations for master and the dev
branch, and rejects the push if it would introduce additional errors
into master.

~~~ruby
#!/usr/bin/env ruby
  
 # Ref update hook for asserting that a topic branch 
 # being merged into a protected
 # branch (e.g. master) does not introduce an increase in 
 # checkstyle violations
 #
 # requires Ruby 1.9.3+ 
  
 require_relative 'ci-util'
 require 'rexml/document'
  
 include REXML
  
 # This example 
 def count_checkstyle_violations(bamboo, commit)
     # grab the checkstyle.xml artifact from the 
     # build (assumes a shared artifact named 
     # 'checkstyle' with 'checkstyle-result.xml' at the root)
     checkstyle_xml = 
         shared_artifact_for_commit(bamboo, commit, 
         bamboo["checkstyle_key"],
        "checkstyle/checkstyle-result.xml")
     doc = Document.new checkstyle_xml
     # could go to town on the comparison here - but let's just count  
     # the raw number of errors for the time being
     XPath.match(doc, "//error").length
 end
  
 # parse args supplied by git: <ref_name> <old_sha> <new_sha>
 ref = simple_branch_name ARGV[0]
 prevCommit = ARGV[1]
 newCommit = ARGV[2]
  
 # test if the updated ref is one we want to enforce green builds for
 exit_if_not_protected_ref(ref)
  
 # get the tip of the most recently merged branch
 tip_of_merged_branch = 
    find_newest_non_merge_commit(prevCommit, newCommit)
  
 # parse our bamboo server config
 bamboo = read_config("bamboo", 
    ["url", "username", "password", "checkstyle_key"])
  
 # calculate number of checkstyle violations for 
 #the old and new commits
 prev_violations = 
     count_checkstyle_violations(bamboo, prevCommit)
 new_violations = 
     count_checkstyle_violations(bamboo, tip_of_merged_branch)
  
 # if the number of checkstyle violations has increased, block the update
 if prev_violations > new_violations
     abort "#{shortSha(tip_of_merged_branch)} 
        has #{new_violations} checkstyle violations! #{ref} 
        currently has only #{prev_violations}." 
 else
     # if the number of checkstyle violations has 
     # decreased, send kudos to the dev
     puts "Nice work! #{ref} has #{new_violations - prev_violations} 
         fewer checkstyle violations than before."
 end
~~~

To get the original source code and surrounding config files for all
the server-side hooks you've seen here, clone the repo at:
[bitbucket.org](https://bitbucket.org/tpettersen/git-ci-hooks).


# Think Globally, Hook Locally

We know that the sooner an issue is discovered, the easier (and faster
and cheaper) it is to fix. That's why hooks that operate on local
clones of a repository are so useful: They offer immediate feedback.
Because we don't get the cmd prompt back until a hook completes,
client-side hooks should be limited to operations that take only a few
seconds, lest the development flow be interrupted. Let's look at two
hooks that complete almost instantly.

# Get Branch Build Status

Exposing branch build status in the terminal window with a
post-checkout hook catches two fish with one worm: It provides
actionable information, and eliminates the need to switch applications
to get it. Upon checkout (and remember, in Git "checkout" means
switching branches, not pulling down code as with SVN and Perforce),
this hook grabs the branch's head revision number from the local copy.
It then queries the CI server to see whether that revision has been
built, and if so, whether the build succeeded.

~~~ruby
#!/usr/bin/env ruby
  
 # post-checkout hook for determining the build status of the 
 # checked out ref from the CI server.
 #
 # Requires Ruby 1.9.3+ 
  
 require 'yaml'
 require 'json'
 require 'net/https'
 require 'uri'
  
 # utility for correctly pluralizing quantities
 def pluralize count, single, multiple
   count == 1 ? single : multiple
 end
  
 # parse args supplied by git
 ref = ARGV[1]       # ref being checked out
 isBranch = ARGV[2]  # 0 = file checkout, 1 = branch checkout
  
 # we only care about branch checkouts 
 if isBranch == "1"
   # initialise build status counts
   failed = successful = in_progress = 0
    
   # loop through each configured Stash server, retrieving build 
   # statuses for the checked out commit and 
   # counting the number of failed, successful and in progress builds
   hookDir = File.expand_path File.dirname(__FILE__)
   configPath = hookDir + "/bamboo-config.yml"
   raise "No bamboo-config.yml found." unless File.exists? configPath
   config = YAML.load_file(configPath)
   raise "bamboo-config.yml file is incomplete: 
       username, password & url are required" unless
       config['url'] and config['username'] and config['password']
      
   # normalize base url
   baseUrl = config['url']
   # assume https if no scheme spcified
   if not baseUrl.start_with? "http"
     baseUrl = "https://#{baseUrl}"
   end
   # strip trailing slashes
   while baseUrl.end_with? "/"
     baseUrl = baseUrl[0..-2]
   end
  
   # prepare a request to hit the build status REST end-point
   build_status_resource = 
       "#{baseUrl}/rest/api/latest/result/byChangeset"
   uri = URI.parse("#{build_status_resource}/#{ref}")
   req = Net::HTTP::Get.new(uri.to_s, initheader = 
       {'Content-Type' => 'application/json', 
           'Accept' => 'application/json'})
   req.basic_auth config['username'], config['password']
   http = Net::HTTP.new(uri.host, uri.port)
   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
   http.use_ssl = uri.scheme.eql?("https")
  
   # execute the request
   response = http.start {|http| http.request(req)}
        
   if not response.is_a? Net::HTTPOK
     puts 'An unknown error occurred while querying 
         Bamboo for build results.'    
     exit    
   else 
     # if the request succeeded, count 
     # the statuses from the response
     body = JSON.parse(response.body)        
     body['results']['result'].collect { |result|
       case result['state']
       when "Failed"
           failed += 1
       when "Successful"
           successful += 1
       when "Unknown"
           if result['lifeCycleState'] == "InProgress"
             in_progress += 1
           end
       end
     }
   end   
  
   # display a short message describing the build status 
   # for the checked out commit
   shortRef = ref[0..7]
   if failed > 0
     puts "Warning! #{shortRef} has #{failed} 
          red #{pluralize(failed, 'build', 'builds')} 
          (plus #{successful} green and #{in_progress} 
          in progress).\nDetails: #{uri}"
   elsif successful == 0
       puts "#{shortRef} hasn't built yet."
   else
        puts "#{shortRef} has #{successful} green 
            #{pluralize(successful, 'build', 'builds')}."
   end
  
 end
~~~

If, for example, the hook tells you the head commit on the master has
built successfully, then it's a "safe" commit to create a feature
branch from. Or let's say the hook says the build for that revision
failed, yet the team's wallboard shows a green build for that branch
(or vice versa). That means the local copy is out-of-date. Whether to
pull down the updates is determined on a case-by-case basis.

This hook and its config files can be found at [bitbucket](https://bitbucket.org/tpettersen/post-checkout-build-status).

# Sanity-Check Code Style

Checking for violations at merge time is great, but a pre-commit hook
analyzing the changeset keeps the style police off your back entirely.
Start by capturing the names of files being updated or added and
concatenating them. That string of file names is then passed into the
Checkstyle run command. If violations are found, the commit is rejected.

Note that despite variations between them, all static analysis tools
can be used with this approach. Findbugs, for example, must be run on
the entire project because it looks at methods referenced across
classes. But that's not necessarily a deal-breaker. Small and
medium-sized projects can be fully analyzed quickly, especially if
a generous heap space is allocated to the process.

# Come As You Are

All the ideas presented here are vendor-neutral. Git hooks may not
revolutionize software development the way continuous integration
has, but every time a task, practice or rule is automated, it's a
win.

From [Dr. Dobbs Journal](http://www.drdobbs.com/architecture-and-design/driving-continuous-integration-from-git/240161383)

