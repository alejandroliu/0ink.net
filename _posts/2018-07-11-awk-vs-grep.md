---
title: Skipping grep when using AWK
---

Over the years, We've seen many people use this pattern (filter-map):

```
$ [data is generated] | grep something | awk '{print $2}'
```

but it can be shortened to:

```
$ [data is generated] | awk '/something/ {print $2}'
```

# You (probably) don't need grep

Following this logic, you can replace a simple grep with:

```
$ [data is generated] | awk '/something/'
```

This will *implicitly* print lines that match the regular expression.

If you feel lost, Here are a series of posts about awk for you:

* https://blog.jpalardy.com/posts/why-learn-awk/
* https://blog.jpalardy.com/posts/awk-tutorial-part-1/
* https://blog.jpalardy.com/posts/awk-tutorial-part-2/
* https://blog.jpalardy.com/posts/awk-tutorial-part-3/

# Why would you want to do this?

There are a number of reasons:

* it's shorter to type
* it spawns one less process
* awk uses modern (read "Perl") regular expressions, by default - like `grep -E`
* it's ready to "augment" with more awk

# What about `grep -v`?

`grep -v` can be done with:

```
$ [data is generated] | awk '! /something/'
```

* * *

Reference: [jpalardy.com](https://blog.jpalardy.com/posts/skip-grep-use-awk/)
