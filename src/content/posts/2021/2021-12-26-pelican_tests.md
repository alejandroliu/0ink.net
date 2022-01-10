---
title: Pelican Test page
tags: address, browser, database, markdown, network
---

[TOC]

This page is used for testing some pelican and markdown extensions
I added.


# shortcodes

OK, this is awkward... I am not sure if this is needed.

# mytags

Using ~~del~~ and ++ins++.

test ??mark?? tags.  How about E=mc^^2^^ and H,,2,,O.

# Drawings

## aafigure

```aafigure
+---------+   +------+   +------------+
|KPN modem+---+router+---+HOME NETWORK|
+---------+   +------+   +------------+
```

```aafigure
      +-----+   ^
      |     |   |
  --->+     +---o--->
      |     |   |
      +-----+   V

       +---+
      /-o-/--
   +-/ / /->
  / *  \/
 +---+  \
      \ /
       +

```


## blockdiag

Block diagram

blockdiag {
    A -> B -> C -> D;
    A -> E -> F -> G;
}

Sequence Diaggram

seqdiag {
  browser  -> webserver [label = "GET /index.html"];
  browser <-- webserver;
  browser  -> webserver [label = "POST /blog/comment"];
              webserver  -> database [label = "INSERT comment"];
              webserver <-- database;
  browser <-- webserver;
}


Activity Diag (Swimlanes?)

actdiag {
  write -> convert -> image

  lane user {
     label = "User"
     write [label = "Writing reST"];
     image [label = "Get diagram IMAGE"];
  }
  lane actdiag {
     convert [label = "Convert reST to Image"];
  }
}

Network Diagram

nwdiag {
  network dmz {
      address = "210.x.x.x/24"

      web01 [address = "210.x.x.1"];
      web02 [address = "210.x.x.2"];
  }
  network internal {
      address = "172.x.x.x/24";

      web01 [address = "172.x.x.1"];
      web02 [address = "172.x.x.2"];
      db01;
      db02;
  }
}

Rack diagram

rackdiag {
  // define height of rack
  16U;

  // define rack items
  1: UPS [2U];
  3: DB Server
  4: Web Server
  5: Web Server
  6: Web Server
  7: Load Balancer
  8: L3 Switch
}

Package diag

packetdiag {
  colwidth = 32
  node_height = 72

  0-15: Source Port
  16-31: Destination Port
  32-63: Sequence Number
  64-95: Acknowledgment Number
  96-99: Data Offset
  100-105: Reserved
  106: URG [rotate = 270]
  107: ACK [rotate = 270]
  108: PSH [rotate = 270]
  109: RST [rotate = 270]
  110: SYN [rotate = 270]
  111: FIN [rotate = 270]
  112-127: Window
  128-143: Checksum
  144-159: Urgent Pointer
  160-191: (Options and Padding)
  192-223: data [colheight = 3]
}

# mdx_include

```python
{! nginx_mod_authrequest/auth1.py !}
```

# GFM style check lists

* [ ] foo
* [x] bar
* [ ] baz

# my mdx variables

We use [snippets](${SNIPPETS}/adhoc-rsync/send-nc) as an example.

How we handle missing ${VARS}.

