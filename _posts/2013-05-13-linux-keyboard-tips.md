---
ID: "74"
post_author: "2"
post_date: "2013-05-13 09:51:41"
post_date_gmt: "2013-05-13 09:51:41"
post_title: Linux Keyboard Tips
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: closed
post_password: ""
post_name: linux-keyboard-tips
to_ping: ""
pinged: ""
post_modified: "2013-05-13 09:51:41"
post_modified_gmt: "2013-05-13 09:51:41"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=74
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Linux Keyboard Tips
...
---

<h1>Turn number pad into a mouse controller</h1>

This comes in handy when working at a <strong>colo</strong> or someplace where you don't have a mouse and then find yourself needing to use <em>X11</em>. Press the following key combo:

<pre><code>Ctrl-Shift-Numlock
</code></pre>

Now the number pad will move the mouse pointer.
The <code>5</code> key is the left-click.

<h1>Special Characters on X11</h1>

The compose key, when pressed in sequence with other keys, produces a Unicode character. E.g., in most configurations pressing <code>&lt;Compose&gt; ' e</code> produces �.

Compose keys appeared on some computer keyboards decades ago, especially those produced by Sun Microsystems. However, it can be enabled on any keyboard with setxkbmap. For example, compose can be set to right alt by running:

<pre><code>setxkbmap -option compose:ralt
</code></pre>

<h2>Compose Sequences</h2>

<pre><code>    |   no-break space                      �  broken bar              ||
    �  soft hyphen             --           �  micro sign              /U
    �  inverted !              !!           �  inverted ?              ??
    �  cent sign            C/ or C|        �  pound sign           L- or L=
    �  currency sign        XO or X0        �  yen sign             Y- or Y=
    �  section sign         SO or S! or S0  �  pilcrow sign            P!
    �  diaeresis            "" or  "        �  macron               _^ or -^
    �  acute accent            ''           �  cedilla                 ,,
    �  copyright sign       CO or C0        �  registered sign         RO
    �  feminine ordinal        A_           �  masculine ordinal       O_
    �  opening angle brackets  &lt;&lt;           �  closing angle brakets   &gt;&gt;
    �  degree sign             0^           �  superscript 1           1^
    �  superscript 2           2^           �  superscript 3           3^
    �  plus or minus sign      +-           �  fraction one-quarter    14
    �  fraction one-half       12           �  fraction three-quarter  34
    �  middle dot           .^ or ..        �  not sign                -,
    �  multiplication sign     xx           �  division sign           :-

    �  A grave                 A`           �  a grave                 a`
    �  A acute                 A'           �  a acute                 a'
    �  A circumflex            A^           �  a circumflex            a^
    �  A tilde                 A~           �  a tilde                 a~
    �  A diaeresis             A"           �  a diaeresis             a"
    �  A ring                  A*           �  a ring                  a*
    �  AE ligature             AE           �  ae ligature             ae

    �  C cedilla               C,           �  c cedilla               c,

    �  E grave                 E`           �  e grave                 e`
    �  E acute                 E'           �  e acute                 e'
    �  E circumflex            E^           �  e circumflex            e^
    �  E diaeresis             E"           �  e diaeresis             e"

    �  I grave                 I`           �  i grave                 i`
    �  I acute                 I'           �  i acute                 i'
    �  I circumflex            I^           �  i circumflex            i^
    �  I diaeresis             I"           �  i diaeresis             i"

    �  capital eth             D-           �  small eth               d-

    �  N tilde                 N~           �  n tilde                 n~

    �  O grave                 O`           �  o grave                 o`
    �  O acute                 O'           �  o acute                 o'
    �  O circumflex            O^           �  o circumflex            o^
    �  O tilde                 O~           �  o tilde                 o~
    �  O diaeresis             O"           �  o diaeresis             o"
    �  O slash                 O/           �  o slash                 o/

    �  U grave                 U`           �  u grave                 u`
    �  U acute                 U'           �  u acute                 u'
    �  U circumflex            U^           �  u circumflex            u^
    �  U diaeresis             U"           �  u diaeresis             u"

    �  Y acute                 Y'           �  y acute                 y'

    �  capital thorn           TH           �  small thorn             th

    �  German small sharp s    ss           �  y diaeresis             y"

    �  Euro                    e=
</code></pre>

<h2>Environment variables</h2>

Some unfriendly applications (including many GTK apps) will override the compose key and default to their own built-in combinations. You can typically fix this by setting environment variables; for instance, you can fix the behavior for GTK with:

<pre><code>export GTK_IM_MODULE=xim
</code></pre>

