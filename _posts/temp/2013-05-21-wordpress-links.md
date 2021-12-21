---
ID: "253"
post_author: "2"
post_date: "2013-05-21 11:59:19"
post_date_gmt: "2013-05-21 11:59:19"
post_title: Wordpress links
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: wordpress-links
to_ping: ""
pinged: ""
post_modified: "2013-05-21 11:59:19"
post_modified_gmt: "2013-05-21 11:59:19"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=253
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Wordpress links
---

This article describes how you creeate hyperlinks within
Wordpress.  There are a number of ways to do this, depending
on the configuration and the types of data we are linking to.

# Linking Without Using Permalinks

This actually works whether or not Permalinks are active. Using the numeric values found in the ID column of the Posts, Categories, and Pages Administration, you can create links as follows.

## Posts

To link to a Post, find the ID of the target post on the Posts administration panel, and insert it in place of the '123' in this link:

```
<a href="index.php?p=123">Post Title</a>

```

## Categories

To link to a Category, find the ID of the target Category on the Categories administration panel, and insert it in place of the '7' in this link:

```
<a href="index.php?cat=7">Category Title</a>

```

## Pages

To link to a Page, find the ID of the target Page on the Pages administration panel, and insert it in place of the '42' in this link:

```
<a href="index.php?page_id=42">Page title</a>

```

## Date-based Archives

```
Year: <a href="index.php?m=2006">2006</a>
Month: <a href="index.php?m=200601">Jan 2006</a>
Day: <a href="index.php?m=20060101">Jan 1, 2006</a> 

```

# Linking Using Permalinks

If you have enabled permalinks, you have a few additional options for providing links that readers of your site will find a bit more user-friendly than the cryptic numbers. For posts, replace each Structure Tag in your permalink structure with the data appropriate to a post to construct a URL for that post. For example, if the permalink structure is:

```
/index.php/archives/%year%/%monthnum%/%day%/%postname%/

```

Replacing the Structure Tags with appropriate values may produce a URL that looks like this:

```
<a href="/index.php/archives/2005/04/22/my-sample-post/">My Sample Post</a>

```

To obtain an accurate URL for a post it may be easier to navigate to the post within the WordPress blog and then copy the URL from one of the blog links that WordPress generates. Review the information at Using Permalinks for more details on constructing URLs for individual posts.

## Categories

To produce a link to a Category using permalinks, obtain the Category Base value from the Options > Permalinks Administration Panel, and append the category name to the end. For example, to link to the category "testing" when the Category Base is "/index.php/categories", use the following link:

```
<a href="/index.php/categories/testing/">category link</a>

```

You can specify a link to a subcategory by using the subcategory directly (as above), or by specifying all parent categories before the category in the URL, like this:

```
<a href="/index.php/categories/parent_category/sub_category/">subcategory link</a>

```

## Pages

Pages have a hierarchy like Categories, and can have parents. If a Page is at the root level of the hierarchy, you can specify just the Page's "page slug" after the static part of your permalink structure:

```
<a href="/index.php/a-test-page">a test page</a>

```

Once again, the best way to verify that this is the correct URL is to navigate to the target Page on the blog and compare the URL to the one you want to use in the link.

## Date-based Archives

```
Year: <a href="/index.php/archives/2006">2006</a>
Month: <a href="/index.php/archives/2006/01/">Jan 2006</a>
Day: <a href="/index.php/archives/2006/01/01/">Jan 1, 2006</a>

```
