---
ID: "109"
post_author: "2"
post_date: "2016-05-22 10:56:55"
post_date_gmt: "2016-05-22 10:56:55"
post_title: Managing our personal finances
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: managing-our-personal-finances
to_ping: ""
pinged: ""
post_modified: "2016-05-22 10:56:55"
post_modified_gmt: "2016-05-22 10:56:55"
post_content_filtered: ""
post_parent: "0"
guid: http://alejandro.iliu.net/wp/?p=109
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Managing our personal finances
date: 2016-05-22
---

During my last vacation I wanted to move how we manage our personal
finances away from the ad-hoc spreadsheet that we had been using for
the past few years. I envisioned something server side, so I wouldn't
need to add software on my wife's computer. And initial quick run
through of server side software did not yield anything that interested
me. In general I could only find _full_ accounting applications, which
would have been an over kill for personal finance/expense tracking. So
then I checked through some desktop applications. I looked at the
following:

*   [HomeBank](http://homebank.free.fr/)
*   [Grisbi](http://www.grisbi.org/)

I found many others, but I only tried these two. The most common
suggestion among Open Source advocates is [GNU Cash](https://www.gnucash.org/),
but I did not try that because it was too big for my modest
requirements. I installed these two but I was not able to get it to do
what I wanted. Which was be able to import transactions from my back
and entered into the the application. So I went back searching to the
web this time looking for "personal finance" instead of "accounting"
and found this web application (amongst others):

*   [PFMGR](https://sourceforge.net/projects/pfmgr/)

So I installed it and was able to run it on my home server. (This was
the first of these types of application that I managed to run, so I was
initially happy). So, running it, it looked OK, had an AJAX based user
interface, etc. Did not have anything in the way to import the data
files from my bank, but since it is Open Source, I could easily make
up something for it. So I modified it to include a page to import my
bank data. This seemed to work OK. That's when the annoyances started.
**PFMGR** author had an specific use case in mind, so it can track not
only money accounts but share accounts. While nice, I did not have
such investments, so that feature was unused, but it will show on the
forms (annoying). A lot of the functionality of the software was around
check reconciliation. Since I don't use checks, that is not useful for
me at all. Finally, I couldn't get the reports to work at all, and the
times that they did work, they did not give me the information that I
wanted. I figured, since this is all open source I could just add/remove
the features the way I wanted. Which curiously turned out I would remove
all the features and just keep **PFMGR** as a simple CRUD application.
So I figure I might as well toss it all out and find a small PHP
Framework that could do CRUD. So I came across this tutorial:

*   [FatFree :: CRUD with MVC](https://foysalmamun.wordpress.com/2013/03/27/fat-free-crud-with-mvc-tutorial/)

So it gives a gentle intro to the [FatFreeFramework](http://fatfreeframework.com/home).
This was just what I was looking for. I can say for simple applications,
this is perfect. I was able to get started into my own personal finance
application. Did run into a few problems. Most of it around the fact that
Fat-Free (aka as F3), although has a very gentle learning curve, and one
can get things started very quickly, it did a few things that I was not
expecting. Well, actually, for a novice programmer, it did things right.
For somebody used to using PHP directly, I would add some code to escape
and protect against invalid inputs, F3 was doing it automatically which
caused me a few headaches until I realized what F3 was doing. My main
problem with F3 is that my schema required a wide varchar column and
that seemed to cause problem with its ORM mapper. Later I will write
a simple test case and see if I can track down the issue.
