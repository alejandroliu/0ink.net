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

1.  User guides  
    Targetted and end-users of the software and people who want a brief overview.
2.  Man pages  
    Again targetted at end-users but also sysadmins. Usually to address a specific feature.
3.  API level documentation/reference guide.  
    Targetted at programmers enhancing, maintaining the software.

To generate I would use different tools. In general we would like to embed with source code.

# User Guides

Either as a stand alone document or embedded in the code. My default
tool is to use [Markdown](http://en.wikipedia.org/wiki/Markdown) as can
be easily be converted to HTML or PDF as needed.

# Man pages

Use `manify`. Embedded in the source code.

# API reference documentation

We need generation tools. So the candidates are:

*   C :
    *   [zehdok](http://www.khm.de/~rudi/ZehDok/)
    *   [mp_doccer](https://github.com/angelortega/mp_doccer)
*   php : Multiples
    *   [phpdoc](http://www.phpdoc.org/): The main one
    *   [peej's phpdoctor](https://github.com/peej/phpdoctor)
    *   [ApiGen](http://www.apigen.org/) : more modern alternative.
    *   [PHP Markdown doc generator](https://github.com/victorjonsson/PHP-Markdown-Documentation-Generator)
*   perl : [pod](http://juerd.nl/site.plp/perlpodtut)
*   python : [pydoc](http://docs.python.org/2/library/pydoc.html)
*   tcl : [tcldoc](http://tcl.jtang.org/tcldoc/tcldoc/) or [doctools](http://www.doxygen.org)
*   java : [javadoc](http://www.oracle.com/technetwork/java/javase/documentation/index-137868.html)
*   javascript : [jsdoc-toolkit](http://code.google.com/p/jsdoc-toolkit/)
*   Shell script: [shdoc](https://github.com/alejandroliu/ashlib/blob/master/shdoc)

Multi languages:

*   [doxygen](http://www.doxygen.org): C, Objective-C, C#, PHP, Java, Python, IDL (Corba, Microsoft, and UNO/OpenOffice flavors), Fortran, VHDL, Tcl, and to some extent D.
*   [ROBODoc](http://rfsber.home.xs4all.nl/Robo/?): Virtually anything.
