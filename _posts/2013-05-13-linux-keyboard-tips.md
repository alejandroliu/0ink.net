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
---

# Turn number pad into a mouse controller

This comes in handy when working at a **colo** or someplace where you
don't have a mouse and then find yourself needing to use _X11_. Press
the following key combo:

    Ctrl-Shift-Numlock

Now the number pad will move the mouse pointer. The `5` key is the
left-click.

## Special Characters on X11


The compose key, when pressed in sequence with other keys, produces a
Unicode character. E.g., in most configurations pressing `Compose` `e`
`\`` produces é. Compose keys appeared on some computer keyboards
decades ago, especially those produced by Sun Microsystems. However,
it can be enabled on any keyboard with setxkbmap. For example, compose
can be set to right alt by running:

    setxkbmap -option compose:ralt

## Compose Sequences

```
    |   no-break space                      ¦  broken bar              ||
    ­  soft hyphen             --           µ  micro sign              /U
    ¡  inverted !              !!           ¿  inverted ?              ??
    ¢  cent sign            C/ or C|        £  pound sign           L- or L=
    ¤  currency sign        XO or X0        ¥  yen sign             Y- or Y=
    §  section sign         SO or S! or S0  ¶  pilcrow sign            P!
    ¨  diaeresis            "" or  "        ¯  macron               _^ or -^
    ´  acute accent            ''           ¸  cedilla                 ,,
    ©  copyright sign       CO or C0        ®  registered sign         RO
    ª  feminine ordinal        A_           º  masculine ordinal       O_
    «  opening angle brackets  &lt;&lt;           »  closing angle brakets   &gt;&gt;
    °  degree sign             0^           ¹  superscript 1           1^
    ²  superscript 2           2^           ³  superscript 3           3^
    ±  plus or minus sign      +-           ¼  fraction one-quarter    14
    ½  fraction one-half       12           ¾  fraction three-quarter  34
    ·  middle dot           .^ or ..        ¬  not sign                -,
    ×  multiplication sign     xx           ÷  division sign           :-

    À  A grave                 A`           à  a grave                 a`
    Á  A acute                 A'           á  a acute                 a'
       A circumflex            A^           â  a circumflex            a^
    Ã  A tilde                 A~           ã  a tilde                 a~
    Ä  A diaeresis             A"           ä  a diaeresis             a"
    Å  A ring                  A*           å  a ring                  a*
    Æ  AE ligature             AE           æ  ae ligature             ae

    Ç  C cedilla               C,           ç  c cedilla               c,

    È  E grave                 E`           &egrave;  e grave                 e`
    É  E acute                 E'           &eacute;  e acute                 e'
    Ê  E circumflex            E^           ê  e circumflex            e^
    Ë  E diaeresis             E"           &euml;  e diaeresis             e"

    Ì  I grave                 I`           ì  i grave                 i`
    Í  I acute                 I'           í  i acute                 i'
    Î  I circumflex            I^           î  i circumflex            i^
    Ï  I diaeresis             I"           ï  i diaeresis             i"

    Ð  capital eth             D-           ð  small eth               d-

    Ñ  N tilde                 N~           ñ  n tilde                 n~

    Ò  O grave                 O`           ò  o grave                 o`
    Ó  O acute                 O'           ó  o acute                 o'
    Ô  O circumflex            O^           ô  o circumflex            o^
    Õ  O tilde                 O~           õ  o tilde                 o~
    Ö  O diaeresis             O"           ö  o diaeresis             o"
    Ø  O slash                 O/           ø  o slash                 o/

    Ù  U grave                 U`           ù  u grave                 u`
    Ú  U acute                 U'           ú  u acute                 u'
    Û  U circumflex            U^           û  u circumflex            u^
    Ü  U diaeresis             U"           ü  u diaeresis             u"

    Ý  Y acute                 Y'           ý  y acute                 y'

    Þ  capital thorn           TH           þ  small thorn             th

    ß  German small sharp s    ss           ÿ  y diaeresis             y"

      Euro                    e=
```

## Environment variables


Some unfriendly applications (including many GTK apps) will override
the compose key and default to their own built-in combinations. You
can typically fix this by setting environment variables; for instance,
you can fix the behavior for GTK with:

    export GTK_IM_MODULE=xim

