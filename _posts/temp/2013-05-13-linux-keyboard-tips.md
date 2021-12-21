---
ID: 74
post_date: 2013-05-13 09:51:41
post_title: Linux Keyboard Tips
post_status: publish
comment_status: open
ping_status: closed
post_name: linux-keyboard-tips
guid: http://s12.pw/wp/?p=74
post_type: post
title: Linux Keyboard Tips
---

Miscellaneous hacks to use the keyboard under Linux.

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
`\`` produces &eacute;. Compose keys appeared on some computer keyboards
decades ago, especially those produced by Sun Microsystems. However,
it can be enabled on any keyboard with setxkbmap. For example, compose
can be set to right alt by running:

    setxkbmap -option compose:ralt

## Compose Sequences

```
    |   no-break space                      &brvbar;  broken bar              ||
    &shy;  soft hyphen             --           &micro;  micro sign              /U
    &iexcl;  inverted !              !!           &iquest;  inverted ?              ??
    &cent;  cent sign            C/ or C|        &pound;  pound sign           L- or L=
    &curren;  currency sign        XO or X0        &yen;  yen sign             Y- or Y=
    &sect;  section sign         SO or S! or S0  &para;  pilcrow sign            P!
    &uml;  diaeresis            &quot;&quot; or  &quot;        &macr;  macron               _^ or -^
    &acute;  acute accent            ''           &cedil;  cedilla                 ,,
    &copy;  copyright sign       CO or C0        &reg;  registered sign         RO
    &ordf;  feminine ordinal        A_           &ordm;  masculine ordinal       O_
    &laquo;  opening angle brackets  &amp;lt;&amp;lt;           &raquo;  closing angle brakets   &amp;gt;&amp;gt;
    &deg;  degree sign             0^           &sup1;  superscript 1           1^
    &sup2;  superscript 2           2^           &sup3;  superscript 3           3^
    &plusmn;  plus or minus sign      +-           &frac14;  fraction one-quarter    14
    &frac12;  fraction one-half       12           &frac34;  fraction three-quarter  34
    &middot;  middle dot           .^ or ..        &not;  not sign                -,
    &times;  multiplication sign     xx           &divide;  division sign           :-

    &Agrave;  A grave                 A`           &agrave;  a grave                 a`
    &Aacute;  A acute                 A'           &aacute;  a acute                 a'
       A circumflex            A^           &acirc;  a circumflex            a^
    &Atilde;  A tilde                 A~           &atilde;  a tilde                 a~
    &Auml;  A diaeresis             A&quot;           &auml;  a diaeresis             a&quot;
    &Aring;  A ring                  A*           &aring;  a ring                  a*
    &AElig;  AE ligature             AE           &aelig;  ae ligature             ae

    &Ccedil;  C cedilla               C,           &ccedil;  c cedilla               c,

    &Egrave;  E grave                 E`           &amp;egrave;  e grave                 e`
    &Eacute;  E acute                 E'           &amp;eacute;  e acute                 e'
    &Ecirc;  E circumflex            E^           &ecirc;  e circumflex            e^
    &Euml;  E diaeresis             E&quot;           &amp;euml;  e diaeresis             e&quot;

    &Igrave;  I grave                 I`           &igrave;  i grave                 i`
    &Iacute;  I acute                 I'           &iacute;  i acute                 i'
    &Icirc;  I circumflex            I^           &icirc;  i circumflex            i^
    &Iuml;  I diaeresis             I&quot;           &iuml;  i diaeresis             i&quot;

    &ETH;  capital eth             D-           &eth;  small eth               d-

    &Ntilde;  N tilde                 N~           &ntilde;  n tilde                 n~

    &Ograve;  O grave                 O`           &ograve;  o grave                 o`
    &Oacute;  O acute                 O'           &oacute;  o acute                 o'
    &Ocirc;  O circumflex            O^           &ocirc;  o circumflex            o^
    &Otilde;  O tilde                 O~           &otilde;  o tilde                 o~
    &Ouml;  O diaeresis             O&quot;           &ouml;  o diaeresis             o&quot;
    &Oslash;  O slash                 O/           &oslash;  o slash                 o/

    &Ugrave;  U grave                 U`           &ugrave;  u grave                 u`
    &Uacute;  U acute                 U'           &uacute;  u acute                 u'
    &Ucirc;  U circumflex            U^           &ucirc;  u circumflex            u^
    &Uuml;  U diaeresis             U&quot;           &uuml;  u diaeresis             u&quot;

    &Yacute;  Y acute                 Y'           &yacute;  y acute                 y'

    &THORN;  capital thorn           TH           &thorn;  small thorn             th

    &szlig;  German small sharp s    ss           &yuml;  y diaeresis             y&quot;

      Euro                    e=
```

## Environment variables


Some unfriendly applications (including many GTK apps) will override
the compose key and default to their own built-in combinations. You
can typically fix this by setting environment variables; for instance,
you can fix the behavior for GTK with:

    export GTK_IM_MODULE=xim

