---
title: Pelican Test page
tags: markdown
---

[TOC]

This page is used for testing some pelican and markdown extensions
I added.


# shortcodes

OK, this is awkward... I am not sure if this is needed.

# mytags

Using ~~del~~ and ++ins++.

test ??mark?? tags.  How about E=mc^^2^^ and H,,2,,O.

# Drawings

## aafigure

```aafigure
+---------+   +------+   +------------+
|KPN modem+---+router+---+HOME NETWORK|
+---------+   +------+   +------------+
```

```aafigure
      +-----+   ^
      |     |   |
  --->+     +---o--->
      |     |   |
      +-----+   V

       +---+
      /-o-/--
   +-/ / /->
  / *  \/
 +---+  \
      \ /
       +

```


## blockdiag

Block diagram

blockdiag {
    A -> B -> C -> D;
    A -> E -> F -> G;
}


# mdx_include

```python
{! nginx_mod_authrequest/auth1.py !}
```

# GFM style check lists

* [ ] foo
* [x] bar
* [ ] baz

# my mdx variables

We use [snippets](https://github.com/alejandroliu/0ink.net/blob/main/snippets/2019/adhoc-rsync/send-nc) as an example.

How we handle missing ${VARS}.

