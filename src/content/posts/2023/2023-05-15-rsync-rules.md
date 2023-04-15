---
title: rsync filter rules
tags: device, directory, information, remote
---
[toc]

The basic options for filtering files in rsync are:

* `--exclude=PATTERN` \
  This option pecifies an exclude rule.
* `--exclude-from=FILE`
  This option is related to the `--exclude` option, but it
  specifies a _FILE_ that contains exclude patterns (one per
  line).  Blank lines in the file are ignored, as are whole-
  line comments that start with ';' or '#' (filename rules
  that contain those characters are unaffected). \
  If a line consists of just "!", then the current filter
  rules are cleared before adding any further rules. \
  If FILE is '-', the list will be read from standard input.
* `--include=PATTERN` \
  This option specifies an include rule.
* `--include-from=FILE`
  This option is related to the `--include` option, but it
  specifies a _FILE_ that contains include patterns (one per
  line).  Blank lines in the file are ignored, as are whole-
  line comments that start with ';' or '#' (filename rules
  that contain those characters are unaffected).\
  If a line consists of just "!", then the current filter
  rules are cleared before adding any further rules.\
  If FILE is '-', the list will be read from standard input.
* `--cvs-exclude`, `-C`\
  This is a useful shorthand for excluding a broad range of
  files that you often don't want to transfer between
  systems.  It uses a similar algorithm to CVS to determine
  if a file should be ignored.\
  The exclude list is initialized to exclude the following
  items (these initial items are marked as perishable:
  ```
  RCS SCCS CVS CVS.adm RCSLOG cvslog.*  tags TAGS
  .make.state .nse_depinfo *~ #* .#* ,* _$* *$ *.old
  *.bak *.BAK *.orig *.rej .del-* *.a *.olb *.o *.obj
  *.so *.exe *.Z *.elc *.ln core .svn/ .git/ .hg/ .bzr/
  ```
  then, files listed in a `$HOME/.cvsignore` are added to the
  list and any files listed in the `CVSIGNORE` environment
  variable (all cvsignore names are delimited by
  whitespace).\
  Finally, any file is ignored if it is in the same
  directory as a `.cvsignore` file and matches one of the
  patterns listed therein.  Unlike rsync's filter/exclude
  files, these patterns are split on whitespace.\
  If you're combining `-C` with your own `--filter` rules, you
  should note that these CVS excludes are appended at the
  end of your own rules, regardless of where the `-C` was
  placed on the command-line.  This makes them a lower
  priority than any rules you specified explicitly.  If you
  want to control where these CVS excludes get inserted into
  your filter rules, you should omit the `-C` as a command-
  line option and use a combination of `--filter=:C` and
  `--filter=-C` (either on your command-line or by putting the
  `":C"` and `"-C"` rules into a filter file with your other
  rules).  The first option turns on the per-directory
  scanning for the `.cvsignore` file.  The second option does
  a one-time import of the CVS excludes mentioned above.

Rsync supports old-style include/exclude rules and new-style
filter rules.  The older rules are specified using `--include` and
`--exclude` as well as the `--include-from` and `--exclude-from`. These
are limited in behavior but they don't require a `"-"` or `"+"`
prefix.  An old-style exclude rule is turned into a `"- name"`
filter rule (with no modifiers) and an old-style include rule is
turned into a `"+ name"` filter rule (with no modifiers).

For more control on included/excluded files you should use
these options:

* `--filter=RULE`, `-f` \
  This option allows you to add rules to selectively exclude
  certain files from the list of files to be transferred.
  This is most useful in combination with a recursive
  transfer.\
  You may use as many `--filter` options on the command line
  as you like to build up the list of files to exclude.  If
  the filter contains whitespace, be sure to quote it so
  that the shell gives the rule to rsync as a single
  argument.  The text below also mentions that you can use
  an underscore to replace the space that separates a rule
  from its arg.
* `-F` \
  The `-F` option is a shorthand for adding two `--filter` rules
  to your command.  The first time it is used is a shorthand
  for this rule:
  ```
  --filter='dir-merge /.rsync-filter'
  ```
  This tells rsync to look for per-directory `.rsync-filter`
  files that have been sprinkled through the hierarchy and
  use their rules to filter the files in the transfer.  If
  `-F` is repeated, it is a shorthand for this rule:
  ```
  --filter='exclude .rsync-filter'
  ```
  This filters out the `.rsync-filter` files themselves from
  the transfer.

# Rules

The filter rules allow for custom control of several aspects of
how files are handled:

- Control which files the sending side puts into the file
  list that describes the transfer hierarchy
- Control which files the receiving side protects from
  deletion when the file is not in the sender's file list
- Control which extended attribute names are skipped when
  copying xattrs

The rules are either directly specified via option arguments or
they can be read in from one or more files.  The filter-rule
files can even be a part of the hierarchy of files being copied,
affecting different parts of the tree in different ways.

# Simple include/exclude rules

We will first cover the basics of how include & exclude rules
affect what files are transferred, ignoring any deletion side-
effects.  Filter rules mainly affect the contents of directories
that rsync is "recursing" into, but they can also affect a top-level
item in the transfer that was specified as a argument.

The default for any unmatched file/dir is for it to be included
in the transfer, which puts the file/dir into the sender's file
list.  The use of an exclude rule causes one or more matching
files/dirs to be left out of the sender's file list.  An include
rule can be used to limit the effect of an exclude rule that is
matching too many files.

The order of the rules is important because the first rule that
matches is the one that takes effect.  Thus, if an early rule
excludes a file, no include rule that comes after it can have any
effect. This means that you must place any include overrides
somewhere prior to the exclude that it is intended to limit.

When a directory is excluded, all its contents and sub-contents
are also excluded.  The sender doesn't scan through any of it at
all, which can save a lot of time when skipping large unneeded
sub-trees.

It is also important to understand that the include/exclude rules
are applied to every file and directory that the sender is
recursing into. Thus, if you want a particular deep file to be
included, you have to make sure that none of the directories that
must be traversed on the way down to that file are excluded or
else the file will never be discovered to be included. As an
example, if the directory "a/path" was given as a transfer
argument and you want to ensure that the file
"a/path/down/deep/wanted.txt" is a part of the transfer, then the
sender must not exclude the directories "a/path", "a/path/down",
or "a/path/down/deep" as it makes it way scanning through the
file tree.

When you are working on the rules, it can be helpful to ask rsync
to tell you what is being excluded/included and why.  Specifying
`--debug=FILTER` or (when pulling files) `-M--debug=FILTER` turns on
level 1 of the `FILTER` debug information that will output a
message any time that a file or directory is included or excluded
and which rule it matched.  Beginning in 3.2.4 it will also warn
if a filter rule has trailing whitespace, since an exclude of
"foo " (with a trailing space) will not exclude a file named
"foo".

Exclude and include rules can specify wildcard **PATTERN MATCHING RULES**
(similar to shell wildcards) that allow you to match things
like a file suffix or a portion of a filename.

A rule can be limited to only affecting a directory by putting a
trailing slash onto the filename.

# Simple include/exclude example

With the following file tree created on the sending side:

```
mkdir x/
touch x/file.txt
mkdir x/y/
touch x/y/file.txt
touch x/y/zzz.txt
mkdir x/z/
touch x/z/file.txt
```

Then the following rsync command will transfer the file
`"x/y/file.txt"` and the directories needed to hold it, resulting
in the path `"/tmp/x/y/file.txt"` existing on the remote host:

```
rsync -ai -f'+ x/' -f'+ x/y/' -f'+ x/y/file.txt' -f'- *' x host:/tmp/
```

Aside: this copy could also have been accomplished using the `-R`
option (though the two commands behave differently if deletions are
enabled):

```
rsync -aiR x/y/file.txt host:/tmp/
```

The following command does not need an include of the `"x"`
directory because it is not a part of the transfer (note the
traililng slash).  Running this command would copy just
`"/tmp/x/file.txt"` because the `"y"` and `"z"` dirs get excluded:

```
rsync -ai -f'+ file.txt' -f'- *' x/ host:/tmp/x/
```

This command would omit the `zzz.txt` file while copying `"x"` and
everything else it contains:

```
rsync -ai -f'- zzz.txt' x host:/tmp/
```

# Filter rules when deleting

By default the include & exclude filter rules affect both the
sender (as it creates its file list) and the receiver (as it
creates its file lists for calculating deletions).  If no delete
option is in effect, the receiver skips creating the delete-
related file lists.  This two-sided default can be manually
overridden so that you are only specifying sender rules or
receiver rules, as described in the
**FILTER RULES IN DEPTH**
section.

When deleting, an exclude protects a file from being removed on
the receiving side while an include overrides that protection
(putting the file at risk of deletion). The default is for a file
to be at risk -- its safety depends on it matching a
corresponding file from the sender.

An example of the two-sided exclude effect can be illustrated by
the copying of a C development directory between two systems.  When
doing a touch-up copy, you might want to skip copying the built
executable and the .o files (sender hide) so that the receiving
side can build their own and not lose any object files that are
already correct (receiver protect).  For instance:

```
rsync -ai --del -f'- *.o' -f'- cmd' src host:/dest/
```

Note that using `-f'-p *.o'` is even better than `-f'- *.o'` if there
is a chance that the directory structure may have changed.  The
`"p"` modifier is discussed in **FILTER RULE MODIFIERS**.

One final note, if your shell doesn't mind unexpanded wildcards,
you could simplify the typing of the filter options by using an
underscore in place of the space and leaving off the quotes.  For
instance, `-f -_*.o -f -_cmd` (and similar) could be used instead
of the filter options above.


# Filter rules in depth

Rsync builds an ordered list of filter rules as specified on the
command-line and/or read-in from files.  New style filter rules
have the following syntax:

```
RULE [PATTERN_OR_FILENAME]
RULE,MODIFIERS [PATTERN_OR_FILENAME]
```
You have your choice of using either short or long _RULE_ names, as
described below.  If you use a short-named rule, the `','`
separating the _RULE_ from the _MODIFIERS_ is optional.  The _PATTERN_
or _FILENAME_ that follows (when present) must come after either a
single space or an underscore (_). Any additional spaces and/or
underscores are considered to be a part of the pattern name.
Here are the available rule prefixes:

* `exclude, '-'` \
  specifies an exclude pattern that (by default) is both a
  hide and a protect.
* `include, '+'` \
  specifies an include pattern that (by default) is both a
  show and a risk.
* `merge, '.'` \
  specifies a merge-file on the client side to read for more
  rules.
* `dir-merge, ':'` \
  specifies a per-directory merge-file.  Using this kind of
  filter rule requires that you trust the sending side's
  filter checking, so it has the side-effect mentioned under
  the `--trust-sender` option.
* `hide, 'H'` \
  specifies a pattern for hiding files from the transfer.
  Equivalent to a sender-only exclude, so `-f'H foo'` could
  also be specified as `-f'-s foo'`.
* `show, 'S'` \
  files that match the pattern are not hidden. Equivalent to
  a sender-only include, so `-f'S foo'` could also be
  specified as `-f'+s foo'`.
* `protect, 'P'` \
  specifies a pattern for protecting files from deletion.
  Equivalent to a receiver-only exclude, so `-f'P foo'` could
  also be specified as `-f'-r foo'`.
* `risk, 'R'` \
  files that match the pattern are not protected. Equivalent
  to a receiver-only include, so `-f'R foo'` could also be
  specified as `-f'+r foo'`.
* `clear, '!'`
  clears the current include/exclude list (takes no arg)

When rules are being read from a file (using `merge` or `dir-merge`),
empty lines are ignored, as are whole-line comments that start
with a `'#'` (filename rules that contain a hash character are
unaffected).

Note also that the `--filter`, `--include`, and `--exclude` options
take one rule/pattern each.  To add multiple ones, you can repeat
the options on the command-line, use the merge-file syntax of the
`--filter` option, or the `--include-from` / `--exclude-from` options.

# Pattern matching rules

Most of the rules mentioned above take an argument that specifies
what the rule should match.  If rsync is recursing through a
directory hierarchy, keep in mind that each pattern is matched
against the name of every directory in the descent path as rsync
finds the filenames to send.

The matching rules for the pattern argument take several forms:

- If a pattern contains a `/` (not counting a trailing slash)
  or a `"**"` (which can match a slash), then the pattern is
  matched against the full pathname, including any leading
  directories within the transfer.  If the pattern doesn't
  contain a (non-trailing) `/` or a `"**"`, then it is matched
  only against the final component of the filename or
  pathname. For example, `foo` means that the final path
  component must be `"foo"` while `foo/bar` would match the last
  2 elements of the path (as long as both elements are
  within the transfer).
- A pattern that ends with a `/` only matches a directory, not
  a regular file, symlink, or device.
- A pattern that starts with a `/` is anchored to the start of
  the transfer path instead of the end.  For example,
  /foo/** or /foo/bar/** match only leading elements in the
  path.  If the rule is read from a per-directory filter
  file, the transfer path being matched will begin at the
  level of the filter file instead of the top of the
  transfer.  See the section on
  **ANCHORING INCLUDE/EXCLUDE PATTERNS**
  for a full discussion of how to specify a pattern
  that matches at the root of the transfer.

Rsync chooses between doing a simple string match and wildcard
matching by checking if the pattern contains one of these three
wildcard characters: '*', '?', and '[' :

- a `'?'` matches any single character except a slash (`/`).
- a `'*'` matches zero or more non-slash characters.
- a `'**'` matches zero or more characters, including slashes.
- a `'['` introduces a character class, such as `[a-z]` or
  `[[:alpha:]]`, that must match one character.
- a trailing `***` in the pattern is a shorthand that allows
  you to match a directory and all its contents using a
  single rule.  For example, specifying `"dir_name/***"` will
  match both the `"dir_name"` directory (as if `"dir_name/"` had
  been specified) and everything in the directory (as if
  `"dir_name/**"` had been specified).
- a backslash can be used to escape a wildcard character,
  but it is only interpreted as an escape character if at
  least one wildcard character is present in the match
  pattern. For instance, the pattern `"foo\bar"` matches that
  single backslash literally, while the pattern `"foo\bar*"`
  would need to be changed to `"foo\\bar*"` to avoid the `"\b"`
  becoming just `"b"`.

Here are some examples of exclude/include matching:

- Option `-f'- *.o'` would exclude all filenames ending with
  `.o`
- Option `-f'- /foo'` would exclude a file (or directory)
  named `foo` in the transfer-root directory
- Option `-f'- foo/'` would exclude any directory named `foo`
- Option `-f'- foo/*/bar'` would exclude any file/dir named
  bar which is at two levels below a directory named `foo` (if
  `foo` is in the transfer)
- Option `-f'- /foo/**/bar'` would exclude any file/dir named
  `bar` that was two or more levels below a top-level
  directory named `foo` (note that `/foo/bar` is not excluded by
  this)
- Options `-f'+ */'` `-f'+ *.c'` `-f'- *'` would include all
  directories and `.c` source files but nothing else
- Options `-f'+ foo/'` `-f'+ foo/bar.c'` `-f'- *'` would include
  only the `foo` directory and `foo/bar.c` (the `foo` directory
  must be explicitly included or it would be excluded by the
  `"- *"`)

# Filter rule modifiers

The following modifiers are accepted after an include `(+)` or
exclude `(-)` rule:

- A `/` specifies that the include/exclude rule should be
  matched against the absolute pathname of the current item.
  For example, `-f'-/ /etc/passwd'` would exclude the `passwd`
  file any time the transfer was sending files from the
  `"/etc"` directory, and `"-/ subdir/foo"` would always exclude
  `"foo"` when it is in a dir named `"subdir"`, even if `"foo"` is
  at the root of the current transfer.
- A `!` specifies that the include/exclude should take effect
  if the pattern fails to match.  For instance, `-f'-! */'`
  would exclude all non-directories.
- A `C` is used to indicate that all the global CVS-exclude
  rules should be inserted as excludes in place of the `"-C"`.
  No arg should follow.
- An `s` is used to indicate that the rule applies to the
  sending side.  When a rule affects the sending side, it
  affects what files are put into the sender's file list.
  The default is for a rule to affect both sides unless
  `--delete-excluded` was specified, in which case default
  rules become sender-side only.  See also the hide `(H)` and
  show `(S)` rules, which are an alternate way to specify
  sending-side includes/excludes.
- An `r` is used to indicate that the rule applies to the
  receiving side.  When a rule affects the receiving side,
  it prevents files from being deleted.  See the `s` modifier
  for more info.  See also the protect `(P)` and risk `(R)`
  rules, which are an alternate way to specify receiver-side
  includes/excludes.
- A `p` indicates that a rule is perishable, meaning that it
  is ignored in directories that are being deleted.  For
  instance, the `--cvs-exclude` `(-C)` option's default rules
  that exclude things like `"CVS"` and `"*.o"` are marked as
  perishable, and will not prevent a directory that was
  removed on the source from being deleted on the
  destination.
- An `x` indicates that a rule affects `xattr` names in `xattr`
  copy/delete operations (and is thus ignored when matching
  file/dir names).  If no xattr-matching rules are
  specified, a default xattr filtering rule is used.

# Merge-file filter rules

You can merge whole files into your filter rules by specifying
either a `merge` (.) or a `dir-merge` (:) filter rule (as introduced
in the **FILTER RULES** section above).

There are two kinds of merged files -- single-instance ('.') and
per-directory (':').  A single-instance merge file is read one
time, and its rules are incorporated into the filter list in the
place of the "." rule.  For per-directory merge files, rsync will
scan every directory that it traverses for the named file,
merging its contents when the file exists into the current list
of inherited rules.  These per-directory rule files must be
created on the sending side because it is the sending side that
is being scanned for the available files to transfer.  These rule
files may also need to be transferred to the receiving side if
you want them to affect what files don't get deleted (see
**PER-DIRECTORY RULES AND DELETE**
below).

Some examples:

```
merge /etc/rsync/default.rules
. /etc/rsync/default.rules
dir-merge .per-dir-filter
dir-merge,n- .non-inherited-per-dir-excludes
:n- .non-inherited-per-dir-excludes
```

The following modifiers are accepted after a merge or dir-merge
rule:

- A `-` specifies that the file should consist of only exclude
  patterns, with no other rule-parsing except for in-file
  comments.
- A `+` specifies that the file should consist of only include
  patterns, with no other rule-parsing except for in-file
  comments.
- A `C` is a way to specify that the file should be read in a
  CVS-compatible manner.  This turns on `'n'`, `'w'`, and `'-'`,
  but also allows the list-clearing token `(!)` to be
  specified.  If no filename is provided, `".cvsignore"` is
  assumed.
- A `e` will exclude the merge-file name from the transfer;
  e.g.  `"dir-merge,e .rules"` is like `"dir-merge .rules"` and
  `"- .rules".`
- An `n` specifies that the rules are not inherited by
  subdirectories.
- A `w` specifies that the rules are word-split on whitespace
  instead of the normal line-splitting.  This also turns off
  comments.  Note: the space that separates the prefix from
  the rule is treated specially, so `"- foo + bar"` is parsed
  as two rules (assuming that prefix-parsing wasn't also
  disabled).
- You may also specify any of the modifiers for the `"+"` or
  `"-"` rules (above) in order to have the rules that are read
  in from the file default to having that modifier set
  (except for the `!` modifier, which would not be useful).
  For instance, `"merge,-/ .excl"` would treat the contents of
  `.excl` as absolute-path excludes, while `"dir-merge,s .filt"`
  and `":sC"` would each make all their per-directory rules
  apply only on the sending side.  If the merge rule
  specifies sides to affect (via the `s` or `r` modifier or
  both), then the rules in the file must not specify sides
  (via a modifier or a rule prefix such as hide).

Per-directory rules are inherited in all subdirectories of the
directory where the merge-file was found unless the `'n'` modifier
was used.  Each subdirectory's rules are prefixed to the
inherited per-directory rules from its parents, which gives the
newest rules a higher priority than the inherited rules.  The
entire set of dir-merge rules are grouped together in the spot
where the merge-file was specified, so it is possible to override
dir-merge rules via a rule that got specified earlier in the list
of global rules.  When the list-clearing rule `("!")` is read from
a per-directory file, it only clears the inherited rules for the
current merge file.

Another way to prevent a single rule from a dir-merge file from
being inherited is to anchor it with a leading slash.  Anchored
rules in a per-directory merge-file are relative to the merge-
file's directory, so a pattern `"/foo"` would only match the file
`"foo"` in the directory where the dir-merge filter file was found.

Here's an example filter file which you'd specify via
`--filter=". file"`:

```
merge /home/user/.global-filter
- *.gz
dir-merge .rules
+ *.[ch]
- *.o
- foo*
```

This will merge the contents of the `/home/user/.global-filter`
file at the start of the list and also turns the `".rules"`
filename into a per-directory filter file.  All rules read in
prior to the start of the directory scan follow the global
anchoring rules (i.e. a leading slash matches at the root of the
transfer).

If a per-directory merge-file is specified with a path that is a
parent directory of the first transfer directory, rsync will scan
all the parent dirs from that starting point to the transfer
directory for the indicated per-directory file.  For instance,
here is a common filter (see -F):

```
--filter=': /.rsync-filter'
```

That rule tells rsync to scan for the file .rsync-filter in all
directories from the root down through the parent directory of
the transfer prior to the start of the normal directory scan of
the file in the directories that are sent as a part of the
transfer. (Note: for an rsync daemon, the root is always the same
as the module's "path".)

Some examples of this pre-scanning for per-directory files:

```
rsync -avF /src/path/ /dest/dir
rsync -av --filter=': ../../.rsync-filter' /src/path/ /dest/dir
rsync -av --filter=': .rsync-filter' /src/path/ /dest/dir
```

The first two commands above will look for `".rsync-filter"` in `"/"`
and `"/src"` before the normal scan begins looking for the file in
`"/src/path"` and its subdirectories.  The last command avoids the
parent-dir scan and only looks for the `".rsync-filter"` files in
each directory that is a part of the transfer.

If you want to include the contents of a `".cvsignore"` in your
patterns, you should use the rule `":C"`, which creates a dir-merge
of the `.cvsignore file`, but parsed in a CVS-compatible manner.
You can use this to affect where the `--cvs-exclude` `(-C)` option's
inclusion of the per-directory .cvsignore file gets placed into
your rules by putting the `":C"` wherever you like in your filter
rules.  Without this, rsync would add the dir-merge rule for the
`.cvsignore` file at the end of all your other rules (giving it a
lower priority than your command-line rules).  For example:

```
cat <<EOT | rsync -avC --filter='. -' a/ b
+ foo.o
:C
- *.old
EOT
rsync -avC --include=foo.o -f :C --exclude='*.old' a/ b
```

Both of the above rsync commands are identical.  Each one will
merge all the per-directory `.cvsignore` rules in the middle of the
list rather than at the end.  This allows their dir-specific
rules to supersede the rules that follow the `:C` instead of being
subservient to all your rules.  To affect the other CVS exclude
rules (i.e. the default list of exclusions, the contents of
`$HOME/.cvsignore`, and the value of `$CVSIGNORE`) you should omit
the `-C` command-line option and instead insert a `"-C"` rule into
your filter rules; e.g.  `"--filter=-C"`.




# List-clearing filter rule

You can clear the current include/exclude list by using the `"!"`
filter rule (as introduced in the
**FILTER RULES**
section above).
The _"current"_ list is either the global list of rules (if the
rule is encountered while parsing the filter options) or a set of
per-directory rules (which are inherited in their own sub-list,
so a subdirectory can use this to clear out the parent's rules).

# Anchoring include/exclude patterns

As mentioned earlier, global include/exclude patterns are
anchored at the "root of the transfer" (as opposed to per-
directory patterns, which are anchored at the merge-file's
directory).  If you think of the transfer as a subtree of names
that are being sent from sender to receiver, the transfer-root is
where the tree starts to be duplicated in the destination
directory.  This root governs where patterns that start with a /
match.

Because the matching is relative to the transfer-root, changing
the trailing slash on a source path or changing your use of the
`--relative` option affects the path you need to use in your
matching (in addition to changing how much of the file tree is
duplicated on the destination host).  The following examples
demonstrate this.

Let's say that we want to match two source files, one with an
absolute path of `"/home/me/foo/bar"`, and one with a path of
`"/home/you/bar/baz"`.  Here is how the various command choices
differ for a 2-source transfer:

```
Example cmd: rsync -a /home/me /home/you /dest
+/- pattern: /me/foo/bar
+/- pattern: /you/bar/baz
Target file: /dest/me/foo/bar
Target file: /dest/you/bar/baz

Example cmd: rsync -a /home/me/ /home/you/ /dest
+/- pattern: /foo/bar               (note missing "me")
+/- pattern: /bar/baz               (note missing "you")
Target file: /dest/foo/bar
Target file: /dest/bar/baz

Example cmd: rsync -a --relative /home/me/ /home/you /dest
+/- pattern: /home/me/foo/bar       (note full path)
+/- pattern: /home/you/bar/baz      (ditto)
Target file: /dest/home/me/foo/bar
Target file: /dest/home/you/bar/baz

Example cmd: cd /home; rsync -a --relative me/foo you/ /dest
+/- pattern: /me/foo/bar      (starts at specified path)
+/- pattern: /you/bar/baz     (ditto)
Target file: /dest/me/foo/bar
Target file: /dest/you/bar/baz
```

The easiest way to see what name you should filter is to just
look at the output when using `--verbose` and put a `/` in front of
the name (use the `--dry-run` option if you're not yet ready to
copy any files).

# Per-directory rules and delete

Without a delete option, per-directory rules are only relevant on
the sending side, so you can feel free to exclude the merge files
themselves without affecting the transfer.  To make this easy,
the `'e'` modifier adds this exclude for you, as seen in these two
equivalent commands:

```
rsync -av --filter=': .excl' --exclude=.excl host:src/dir /dest
rsync -av --filter=':e .excl' host:src/dir /dest
```

However, if you want to do a delete on the receiving side AND you
want some files to be excluded from being deleted, you'll need to
be sure that the receiving side knows what files to exclude.  The
easiest way is to include the per-directory merge files in the
transfer and use `--delete-after`, because this ensures that the
receiving side gets all the same exclude rules as the sending
side before it tries to delete anything:

```
rsync -avF --delete-after host:src/dir /dest
```

However, if the merge files are not a part of the transfer,
you'll need to either specify some global exclude rules (i.e.
specified on the command line), or you'll need to maintain your
own per-directory merge files on the receiving side.  An example
of the first is this (assume that the remote .rules files exclude
themselves):

```
rsync -av --filter=': .rules' --filter='. /my/extra.rules' --delete host:src/dir /dest
```

In the above example the extra.rules file can affect both sides
of the transfer, but (on the sending side) the rules are
subservient to the rules merged from the `.rules` files because
they were specified after the per-directory merge rule.

In one final example, the remote side is excluding the
`.rsync-filter` files from the transfer, but we want to use our own
`.rsync-filter` files to control what gets deleted on the receiving
side.  To do this we must specifically exclude the per-directory
merge files (so that they don't get deleted) and then put rules
into the local files to control what else should not get deleted.
Like one of these commands:

```
rsync -av --filter=':e /.rsync-filter' --delete host:src/dir /dest
rsync -avFF --delete host:src/dir /dest
```
