---
title: Writing Safe Shell scripts
date: "2023-08-27"
author: alex
ID: "1008"
post_author: "2"
post_date: "2016-11-23 11:50:22"
post_date_gmt: "2016-11-23 11:50:22"
post_title: Writing Safe Shell scripts
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: writing-safe-shell-scripts
to_ping: ""
pinged: ""
post_modified: "2016-11-23 11:50:22"
post_modified_gmt: "2016-11-23 11:50:22"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=1008
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
tags: configuration, directory, python, scripts, security, settings, tools, sudo,
  idea
---
Writing shell scripts leaves a lot of room to make mistakes, in ways that will cause
your scripts to break on certain input, or (if some input is untrusted) open up security
vulnerabilities. Here are some tips on how to make your shell scripts safer.

# Don't

The simplest step is to avoid using shell at all. Many higher-level languages are both
easier to write the code in in the first place, and avoid some of the issues that shell
has. For example, Python will automatically error out if you try to read from an
uninitialized variable (though not if you try to write to one), or if some function call
you make produces an error.

One of shell's chief advantages is that it's easy to call out to the huge variety of
command-line utilities available. Much of that functionality will be available through
libraries in Python or other languages. For the handful of things that aren't, you can
still call external programs. In Python, the
[subprocess](https://docs.python.org/2/library/subprocess.html)
module is very useful for this.  You should try to avoid passing `shell=True` to `subprocess`
(or using `os.system` or similar functions at all), since that will run a shell, exposing
you to many of the same issues as plain shell has. It also has two big advantages over
shell: it's a lot easier to avoid
[word-splitting](http://www.gnu.org/software/bash/manual/html_node/Word-Splitting.html)
or similar issues, and since calls to `subprocess` will tend to be relatively uncommon,
it's easy to scrutinize them especially hard. When using `subprocess` or similar tools,
you should still be aware of the suggestions in "Passing filenames or other positional
arguments to commands" below.

# Shell settings

POSIX sh and especially bash have a number of settings that can help write safe shell
scripts.

I recommend the following in bash scripts:

```bash
set -euf -o pipefail
```

In dash, `set -o` doesn't exist, so use only `set -euf`.

What do those do?

[set -e](http://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)

If a command fails, `set -e` will make the whole script exit, instead of just resuming
on the next line. If you have commands that can fail without it being an issue, you can
append `|| true` or `|| :` to suppress this behavior - for example `set -e` followed by
`false || :` will not cause your script to terminate.

[set -u](http://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)

Treat unset variables as an error, and immediately exit.

[set -f](http://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)

Disable filename expansion (globbing) upon seeing `*`, `?`, etc..

If your script depends on globbing, you obviously shouldn't set this. Instead, you may find
[shopt -s failglob](http://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html)
useful, which causes globs that don't get expanded to cause errors, rather than getting
passed to the command with the `*` intact.

[set -o pipefail](http://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)

`set -o pipefail` causes a pipeline (for example, `curl -s http://sipb.mit.edu/ | grep foo`) to produce a failure return code if any command errors. Normally, pipelines only return a failure if the last command errors. In combination with `set -e`, this will make your script exit if any command in a pipeline errors.

# Quote liberally

Whenever you pass a variable to a command, you should probably quote it. Otherwise, the shell
will perform
[word-splitting](http://www.gnu.org/software/bash/manual/html_node/Word-Splitting.html) and
[globbing](http://www.gnu.org/software/bash/manual/html_node/Filename-Expansion.html),
which is likely not what you want.

For example, consider the following:

```bash
alex@kronborg tmp [15:23] $ dir="foo bar"
alex@kronborg tmp [15:23] $ ls $dir
ls: cannot access foo: No such file or directory
ls: cannot access bar: No such file or directory
alex@kronborg tmp [15:23] $ cd "$dir"
alex@kronborg foo bar [15:25] $ file=*.txt
alex@kronborg foo bar [15:26] $ echo $file
bar.txt foo.txt
alex@kronborg foo bar [15:26] $ echo "$file"
*.txt
```

Depending on what you are doing in your script, it is likely that the word-splitting and
globbing shown above are not what you expected to have happen. By using `"$foo"` to access
the contents of the `foo` variable instead of just `$foo`, this problem does not arise.

When writing a wrapper script, you may wish pass along all the arguments your script
received. Do that with:

```bash
wrapped-command "$@"
```

See
["Special Parameters" in the bash manual](http://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html)
for details on the distinction between `$*`, `$@`, and `"$@"` - the first and second are
rarely what you want in a safe shell script.

# Passing filenames or other positional arguments to commands

If you get filenames from the user or from shell globbing, or any other kind of
positional arguments, you should be aware that those could start with a `"-"`. Even if you
quote correctly, this may still act differently from what you intended. For example,
consider a script that allows somebody to run commands as `nobody` (exposed over `remctl`,
perhaps), consisting of just `sudo -u nobody "$@"`. The quoting is fine, but if a user
passes `-u root reboot`, `sudo` will catch the second `-u` and run it as `root`.

Fixing this depends on what command you're running.

For many commands, however, `--` is accepted to indicate that any options are done,
and future arguments should be parsed as positional parameters - even if they look like
options. In the `sudo` example above, `sudo -u nobody -- "$@"` would avoid this attack
(though obviously specifying in the `sudo` configuration that commands can only be run
as `nobody` is also a good idea).

Another approach is to prefix each filename with `./`, if the filenames are expected to be in the current directory.

# Temporary files

A common convention to create temporary file names is to use `something.$$`.  This is not
safe.  It is better to use `mktemp`.

# Other resources

Google has a [Shell Style Guide](https://google.github.io/styleguide/shell.xml).
As the name suggests, it primarily focuses on good style, but some items are
safety/security-relevant.

# Conclusion

When possible, instead of writing a "safe" shell script, **use a higher-level language
like Python**. If you can't do that, the shell has several options that you can enable that
will reduce your chances of having bugs, and you should be sure to quote liberally.


Source [Writing Safe Shell](https://sipb.mit.edu/doc/safe-shell/).

