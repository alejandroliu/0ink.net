---
ID: "390"
post_author: "2"
post_date: "2013-05-29 13:17:03"
post_date_gmt: "2013-05-29 13:17:03"
post_title: Program Documentation
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: program-documentation
to_ping: ""
pinged: ""
post_modified: "2013-05-29 13:17:03"
post_modified_gmt: "2013-05-29 13:17:03"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=390
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Program Documentation

---

So these are my ideas on how to document projects. There are three types of documentation types:

<ol>
<li>User guides<br />
Targetted and end-users of the software and people who want a brief overview.</li>
<li>Man pages<br />
Again targetted at end-users but also sysadmins. Usually to address a specific feature.</li>
<li>API level documentation/reference guide.<br />
Targetted at programmers enhancing, maintaining the software.</li>
</ol>

To generate I would use different tools. In general we would like to embed with source code.

<h1>User Guides</h1>

Either as a stand alone document or embedded in the code. My default tool is to use <a href="http://en.wikipedia.org/wiki/Markdown">Markdown</a> as can be easily be converted to HTML or PDF as needed.

<h1>Man pages</h1>

Use <code>manify</code>. Embedded in the source code.

<h1>API reference documentation</h1>

We need generation tools. So the candidates are:

<ul>
<li>C : 

<ul>
<li><a href="http://www.khm.de/~rudi/ZehDok/">zehdok</a></li>
<li><a href="https://github.com/angelortega/mp_doccer">mp_doccer</a></li>
</ul></li>
<li>php : Multiples

<ul>
<li><a href="http://www.phpdoc.org/">phpdoc</a>: The main one</li>
<li><a href="https://github.com/peej/phpdoctor">peej's phpdoctor</a></li>
<li><a href="http://www.apigen.org/">ApiGen</a> : more modern alternative.</li>
<li><a href="https://github.com/victorjonsson/PHP-Markdown-Documentation-Generator">PHP Markdown doc generator</a></li>
</ul></li>
<li>perl : <a href="http://juerd.nl/site.plp/perlpodtut">pod</a></li>
<li>python : <a href="http://docs.python.org/2/library/pydoc.html">pydoc</a></li>
<li>tcl : <a href="http://tcl.jtang.org/tcldoc/tcldoc/">tcldoc</a> or <a href="http://www.doxygen.org">doctools</a></li>
<li>java : <a href="http://www.oracle.com/technetwork/java/javase/documentation/index-137868.html">javadoc</a></li>
<li>javascript : <a href="http://code.google.com/p/jsdoc-toolkit/">jsdoc-toolkit</a></li>
<li>Shell script: <a href="https://github.com/alejandroliu/ashlib/blob/master/shdoc">shdoc</a></li>
</ul>

Multi languages:

<ul>
<li><a href="http://www.doxygen.org">doxygen</a>: C, Objective-C, C#, PHP, Java, Python, IDL (Corba, Microsoft, and UNO/OpenOffice flavors), Fortran, VHDL, Tcl, and to some extent D.</li>
<li><a href="http://rfsber.home.xs4all.nl/Robo/?">ROBODoc</a>: Virtually anything.</li>
</ul>
