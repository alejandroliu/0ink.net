---
ID: "663"
post_author: "2"
post_date: "2013-09-06 08:55:23"
post_date_gmt: "2013-09-06 08:55:23"
post_title: Parsing JSON in Shell scripts
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: parsing-json-in-shell-scripts
to_ping: ""
pinged: ""
post_modified: "2013-09-06 08:55:23"
post_modified_gmt: "2013-09-06 08:55:23"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=663
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Parsing JSON in Shell scripts

date: 2013-09-06
---

This can be simple by using <a href="http://stedolan.github.io/jq/">jq</a>.

This is a command line JSON processor.  Here are a couple of examples of what can be done:

<pre><code>$ cat json.txt

{
        "name": "Google",
        "location":
                {
                        "street": "1600 Amphitheatre Parkway",
                        "city": "Mountain View",
                        "state": "California",
                        "country": "US"
                },
        "employees":
                [
                        {
                                "name": "Michael",
                                "division": "Engineering"
                        },
                        {
                                "name": "Laura",
                                "division": "HR"
                        },
                        {
                                "name": "Elise",
                                "division": "Marketing"
                        }
                ]
}
</code></pre>

To parse a JSON object:

<pre><code>jq '.name' &lt; json.txt

"Google"
</code></pre>

To parse a nested JSON object:

<pre><code>$ jq '.location.city' &lt; json.txt

"Mountain View"
</code></pre>

To parse a JSON array:

<pre><code>$ jq '.employees[0].name' &lt; json.txt

"Michael"
</code></pre>

To extract specific fields from a JSON object:

<pre><code>$ jq '.location | {street, city}' &lt; json.txt

{
  "city": "Mountain View",
  "street": "1600 Amphitheatre Parkway"
}
</code></pre>

