---
title: Markdown cheat sheet
tags: application, github, markdown
---

This is intended as a quick reference and showcase. For more complete info,
see [John Gruber's original spec](http://daringfireball.net/projects/markdown/)
and the [Github-flavored Markdown info page](http://github.github.com/github-flavored-markdown/).

# Headers

Source:

***

```markdown
# H1
## H2
### H3
#### H4
##### H5
###### H6

Alternatively, for H1 and H2, an underline-ish style:

Alt-H1
======

Alt-H2
------
```
***

Output:

***
# H1
## H2
### H3
#### H4
##### H5
###### H6


Alternatively, for H1 and H2, an underline-ish style:

Alt-H1
======

Alt-H2
------
***

# Emphasis

Source:

***

```markdown
Emphasis, aka italics, with *asterisks* or _underscores_.

Strong emphasis, aka bold, with **asterisks** or __underscores__.

Combined emphasis with **asterisks and _underscores_**.

Strikethrough uses two tildes. ~~Scratch this.~~
```
***

Output:

***

Emphasis, aka italics, with *asterisks* or _underscores_.

Strong emphasis, aka bold, with **asterisks** or __underscores__.

Combined emphasis with **asterisks and _underscores_**.

Strikethrough uses two tildes. ~~Scratch this.~~

***

# Lists

(In this example, leading and trailing spaces are shown with with dots: ⋅)

Source:

***

```markdown
1. First ordered list item
2. Another item
⋅⋅* Unordered sub-list.
1. Actual numbers don't matter, just that it's a number
⋅⋅1. Ordered sub-list
4. And another item.

⋅⋅⋅You can have properly indented paragraphs within list items. Notice the blank line above, and the leading spaces (at least one, but we'll use three here to also align the raw Markdown).

⋅⋅⋅To have a line break without a paragraph, you will need to use two trailing spaces.⋅⋅
⋅⋅⋅Note that this line is separate, but within the same paragraph.⋅⋅
⋅⋅⋅(This is contrary to the typical GFM line break behaviour, where trailing spaces are not required.)

* Unordered list can use asterisks
- Or minuses
+ Or pluses
```
***

Output:

***

1. First ordered list item
2. Another item
  * Unordered sub-list.
1. Actual numbers don't matter, just that it's a number
  1. Ordered sub-list
4. And another item.

   You can have properly indented paragraphs within list items. Notice the blank line above, and the leading spaces (at least one, but we'll use three here to also align the raw Markdown).

   To have a line break without a paragraph, you will need to use two trailing spaces.
   Note that this line is separate, but within the same paragraph.
   (This is contrary to the typical GFM line break behaviour, where trailing spaces are not required.)

* Unordered list can use asterisks
- Or minuses
+ Or pluses


***


# Links

There are two ways to create links.

Source:

***

```markdown
[I'm an inline-style link](https://www.google.com)

[I'm an inline-style link with title](https://www.google.com "Google's Homepage")

[I'm a reference-style link][Arbitrary case-insensitive reference text]

[I'm a relative reference to a repository file](../blob/master/LICENSE)

[You can use numbers for reference-style link definitions][1]

Or leave it empty and use the [link text itself].

URLs and URLs in angle brackets will automatically get turned into links.
http://www.example.com or <http://www.example.com> and sometimes
example.com (but not on Github, for example).

Some text to show that the reference links can follow later.

[arbitrary case-insensitive reference text]: https://www.mozilla.org
[1]: http://slashdot.org
[link text itself]: http://www.reddit.com
```
***

Output:

***

[I'm an inline-style link](https://www.google.com)

[I'm an inline-style link with title](https://www.google.com "Google's Homepage")

[I'm a reference-style link][Arbitrary case-insensitive reference text]

[I'm a relative reference to a repository file](../blob/master/LICENSE)

[You can use numbers for reference-style link definitions][1]

Or leave it empty and use the [link text itself].

URLs and URLs in angle brackets will automatically get turned into links.
http://www.example.com or <http://www.example.com> and sometimes
example.com (but not on Github, for example).

Some text to show that the reference links can follow later.

[arbitrary case-insensitive reference text]: https://www.mozilla.org
[1]: http://slashdot.org
[link text itself]: http://www.reddit.com

***

# Images

Source:

***

```markdown
Here's our logo (hover to see the title text):

Inline-style:
![alt text](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 1")

Reference-style:
![alt text][logo]

[logo]: https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 2"
```
***

Output:

***

Here's our logo (hover to see the title text):

Inline-style:
![alt text](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 1")

Reference-style:
![alt text][logo]

[logo]: https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 2"

***



# Code and Syntax Highlighting

Code blocks are part of the Markdown spec, but syntax highlighting isn't.
However, many renderers support syntax highlighting. Which languages are supported
and how those language names should be written will vary from renderer to renderer.

To see the complete list, and how to write the language names, see the
[highlight.js demo page](http://softwaremaniacs.org/media/soft/highlight/test.html).

Source:

***

```markdown
Inline `code` has `back-ticks around` it.
```

***

Output:

***

Inline `code` has `back-ticks around` it.

***

Blocks of code are either fenced by lines with three back-ticks
"\`\`\`",
or are indented with four spaces. I recommend only using the fenced code
blocks -- they're easier and only they support syntax highlighting.

Source:

***

<pre lang="no-highlight"><code>```javascript
var s = "JavaScript syntax highlighting";
alert(s);
```

```python
s = "Python syntax highlighting"
print s
```

```
No language indicated, so no syntax highlighting.
But let's throw in a &lt;b&gt;tag&lt;/b&gt;.
```
</code></pre>

***

Output:

```javascript
var s = "JavaScript syntax highlighting";
alert(s);
```

```python
s = "Python syntax highlighting"
print s
```

```
No language indicated, so no syntax highlighting in Markdown Here (varies on Github).
But let's throw in a <b>tag</b>.
```
***

# Tables

Tables aren't part of the core Markdown spec, but they are part of GFM. They
are an easy way of adding tables to your email -- a task that would otherwise
require copy-pasting from another application.

Source:

***
```markdown
Colons can be used to align columns.

| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |

There must be at least 3 dashes separating each header cell.
The outer pipes (|) are optional, and you don't need to make the
raw Markdown line up prettily. You can also use inline Markdown.

Markdown | Less | Pretty
--- | --- | ---
*Still* | `renders` | **nicely**
1 | 2 | 3
```
***

Output:

***


Colons can be used to align columns.

| Tables        | Are           | Cool |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |

There must be at least 3 dashes separating each header cell. The outer pipes (|)
are optional, and you don't need to make the raw Markdown line up prettily. You
can also use inline Markdown.

Markdown | Less | Pretty
--- | --- | ---
*Still* | `renders` | **nicely**
1 | 2 | 3

***


# Blockquotes

Source:

***

```markdown
> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.

Quote break.

> This is a very long line that will still be quoted properly when it wraps. Oh boy let's keep writing to make sure this is long enough to actually wrap for everyone. Oh, you can *put* **Markdown** into a blockquote.
```
***

Output:

***

> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.

Quote break.

> This is a very long line that will still be quoted properly when it wraps. Oh boy let's keep writing to make sure this is long enough to actually wrap for everyone. Oh, you can *put* **Markdown** into a blockquote.

***

# Inline HTML

You can also use raw HTML in your Markdown, and it'll mostly work pretty well.

Source:

***

```markdown
<dl>
  <dt>Definition list</dt>
  <dd>Is something people use sometimes.</dd>

  <dt>Markdown in HTML</dt>
  <dd>Does *not* work **very** well. Use HTML <em>tags</em>.</dd>
</dl>
```
***

Output:

***

<dl>
  <dt>Definition list</dt>
  <dd>Is something people use sometimes.</dd>

  <dt>Markdown in HTML</dt>
  <dd>Does *not* work **very** well. Use HTML <em>tags</em>.</dd>
</dl>

***

# Horizontal Rule

Source:

***

```
Three or more...

---

Hyphens

***

Asterisks

___

Underscores
```
***

Output:

***

Three or more...

---

Hyphens

***

Asterisks

___

Underscores

***


# Line Breaks

My basic recommendation for learning how line breaks work is to experiment and
discover -- hit &lt;Enter&gt; once (i.e., insert one newline), then hit it twice
(i.e., insert two newlines), see what happens. You'll soon learn to get what you
want. "Markdown Toggle" is your friend.

Here are some things to try out:

Source:

***

```markdown
Here's a line for us to start with.

This line is separated from the one above by two newlines, so it will be a *separate paragraph*.

This line is also a separate paragraph, but...
This line is only separated by a single newline, so it's a separate line in the *same paragraph*.
```
***

Output:

***

Here's a line for us to start with.

This line is separated from the one above by two newlines, so it will be a *separate paragraph*.

This line is also begins a separate paragraph, but...
This line is only separated by a single newline, so it's a separate line in the *same paragraph*.

(Technical note: *Markdown Here* uses GFM line breaks, so there's no need to use MD's two-space line breaks.)

***

# Local extensions

Source:

***
```markdown
- [x] ticked checkboxes
- [ ] unticked check box
- Use ++insert++ text
- This is ^^superscript^^ stuff.
- This is ,,subscript,, stuff.
- This is ~~striketrough~~ text.
- This is ??marked?? text.

```
***

Output:

***
- [x] ticked checkboxes
- [ ] unticked check box
- Use ++insert++ text
- This is ^^superscript^^ stuff.
- This is ,,subscript,, stuff.
- This is ~~striketrough~~ text.
- This is ??marked?? text.

***

# Diagrams

Source:

***
<pre lang="no-highlight"><code>dot {
  graph NET {
    layout=neato

    edge [weight=2.0 fontsize=7]
    node [style=filled shape=box]

    node [fillcolor=white] kpnmodem
    node [fillcolor=lightblue] ngs1 ngs2 ngs3
    node [fillcolor=lightgreen] cctv_sw
    node [fillcolor=silver] cn4 iptv1 veraedge1 nd2 nd3 philtv
    node [fillcolor=yellow] wac1 wac2 wac3 owap1

    kpnmodem -- cn4 [label="v2" taillabel="p1" headlabel="p2"]
    kpnmodem -- iptv1 [label="v2 (p#7)" taillabel="p2"]
    kpnmodem -- veraedge1 [label="v2" taillabel="p4"]

    ngs1 -- cn4 [label="v1,3" taillabel="p10" headlabel="p0"]
    ngs1 -- ngs2 [label="v1,3 (p#4)" taillabel="p1" headlabel="p1"]
    ngs1 -- ngs3 [label="v1,3" taillabel="p8,9" headlabel="p1,8" penwidth=2.0]
    ngs1 -- cctv_sw [label="v3" taillabel="p7" headlabel="p5"]

    ngs3 -- nd2 [label="v1,3" taillabel="p7"]
    ngs3 -- nd3 [label="v1,3" taillabel="p8"]

    cctv_sw -- ipcam1 [label="v3" taillabel="p1"]
    cctv_sw -- ipcam2 [label="v3 (p#1)" taillabel="p2"]
    cctv_sw -- ipcam3 [label="v3 (p#5)" taillabel="p3"]
  }
}

\```aafigure {"foreground": "#ff0000"}
      +-----+   ^
      |     |   |
  --->+     +---o--->
      |     |   |
      +-----+   V
```
</code></pre>
***

Output:

***

dot {
  graph NET {
    layout=neato

    edge [weight=2.0 fontsize=7]
    node [style=filled shape=box]

    node [fillcolor=white] kpnmodem
    node [fillcolor=lightblue] ngs1 ngs2 ngs3
    node [fillcolor=lightgreen] cctv_sw
    node [fillcolor=silver] cn4 iptv1 veraedge1 nd2 nd3 philtv
    node [fillcolor=yellow] wac1 wac2 wac3 owap1

    kpnmodem -- cn4 [label="v2" taillabel="p1" headlabel="p2"]
    kpnmodem -- iptv1 [label="v2 (p#7)" taillabel="p2"]
    kpnmodem -- veraedge1 [label="v2" taillabel="p4"]

    ngs1 -- cn4 [label="v1,3" taillabel="p10" headlabel="p0"]
    ngs1 -- ngs2 [label="v1,3 (p#4)" taillabel="p1" headlabel="p1"]
    ngs1 -- ngs3 [label="v1,3" taillabel="p8,9" headlabel="p1,8" penwidth=2.0]
    ngs1 -- cctv_sw [label="v3" taillabel="p7" headlabel="p5"]

    ngs3 -- nd2 [label="v1,3" taillabel="p7"]
    ngs3 -- nd3 [label="v1,3" taillabel="p8"]

    cctv_sw -- ipcam1 [label="v3" taillabel="p1"]
    cctv_sw -- ipcam2 [label="v3 (p#1)" taillabel="p2"]
    cctv_sw -- ipcam3 [label="v3 (p#5)" taillabel="p3"]
  }
}

```aafigure {"foreground": "#ff0000"}
      +-----+   ^
      |     |   |
  --->+     +---o--->
      |     |   |
      +-----+   V
```
***

# Others

- `#++` and `#--` for headown
- `$include: file.md $`

