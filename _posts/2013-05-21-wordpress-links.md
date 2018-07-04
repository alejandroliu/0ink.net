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

<h1>Linking Without Using Permalinks</h1>

This actually works whether or not Permalinks are active.

Using the numeric values found in the ID column of the Posts, Categories, and Pages Administration, you can create links as follows.

<h2>Posts</h2>

To link to a Post, find the ID of the target post on the Posts administration panel, and insert it in place of the '123' in this link:

<pre><code>&lt;a href="index.php?p=123"&gt;Post Title&lt;/a&gt;
</code></pre>

<h2>Categories</h2>

To link to a Category, find the ID of the target Category on the Categories administration panel, and insert it in place of the '7' in this link:

<pre><code>&lt;a href="index.php?cat=7"&gt;Category Title&lt;/a&gt;
</code></pre>

<h2>Pages</h2>

To link to a Page, find the ID of the target Page on the Pages administration panel, and insert it in place of the '42' in this link:

<pre><code>&lt;a href="index.php?page_id=42"&gt;Page title&lt;/a&gt;
</code></pre>

<h2>Date-based Archives</h2>

<pre><code>Year: &lt;a href="index.php?m=2006"&gt;2006&lt;/a&gt;
Month: &lt;a href="index.php?m=200601"&gt;Jan 2006&lt;/a&gt;
Day: &lt;a href="index.php?m=20060101"&gt;Jan 1, 2006&lt;/a&gt; 
</code></pre>

<h1>Linking Using Permalinks</h1>

If you have enabled permalinks, you have a few additional options for providing links that readers of your site will find a bit more user-friendly than the cryptic numbers.

For posts, replace each Structure Tag in your permalink structure with the data appropriate to a post to construct a URL for that post. For example, if the permalink structure is:

<pre><code>/index.php/archives/%year%/%monthnum%/%day%/%postname%/
</code></pre>

Replacing the Structure Tags with appropriate values may produce a URL that looks like this:

<pre><code>&lt;a href="/index.php/archives/2005/04/22/my-sample-post/"&gt;My Sample Post&lt;/a&gt;
</code></pre>

To obtain an accurate URL for a post it may be easier to navigate to the post within the WordPress blog and then copy the URL from one of the blog links that WordPress generates.

Review the information at Using Permalinks for more details on constructing URLs for individual posts.

<h2>Categories</h2>

To produce a link to a Category using permalinks, obtain the Category Base value from the Options &gt; Permalinks Administration Panel, and append the category name to the end.

For example, to link to the category "testing" when the Category Base is "/index.php/categories", use the following link:

<pre><code>&lt;a href="/index.php/categories/testing/"&gt;category link&lt;/a&gt;
</code></pre>

You can specify a link to a subcategory by using the subcategory directly (as above), or by specifying all parent categories before the category in the URL, like this:

<pre><code>&lt;a href="/index.php/categories/parent_category/sub_category/"&gt;subcategory link&lt;/a&gt;
</code></pre>

<h2>Pages</h2>

Pages have a hierarchy like Categories, and can have parents. If a Page is at the root level of the hierarchy, you can specify just the Page's "page slug" after the static part of your permalink structure:

<pre><code>&lt;a href="/index.php/a-test-page"&gt;a test page&lt;/a&gt;
</code></pre>

Once again, the best way to verify that this is the correct URL is to navigate to the target Page on the blog and compare the URL to the one you want to use in the link.

<h2>Date-based Archives</h2>

<pre><code>Year: &lt;a href="/index.php/archives/2006"&gt;2006&lt;/a&gt;
Month: &lt;a href="/index.php/archives/2006/01/"&gt;Jan 2006&lt;/a&gt;
Day: &lt;a href="/index.php/archives/2006/01/01/"&gt;Jan 1, 2006&lt;/a&gt;
</code></pre>

