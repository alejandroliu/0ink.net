---
ID: "11"
post_author: "2"
post_date: "2013-07-01 10:20:19"
post_date_gmt: "2013-07-01 10:20:19"
post_title: Askozia Desktop Appliance
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: askozia-desktop-appliance
to_ping: ""
pinged: ""
post_modified: "2016-10-28 15:22:43"
post_modified_gmt: "2016-10-28 15:22:43"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=11
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Askozia Desktop Appliance
date: 2013-07-01
---

![Askozia Logo]({{ site.url }}/images/2013/askozia_logo.png)

So last weekend finally had some time to work with a [Askozia](http://askozia.com/ "Askozia PBX") Desktop Appliance.

It actually arrived much earlier but without a Power Supply. Initially I though, "this is strange; I didn't know this supported PoE". (Power Over Ethernet). It turns out it didn't and there was a shipping mistake. After contacting the vendor, they sent me the required Power Supply.

Overall I think the product is quite nice. It has a very nice User Interface that is quite easy to use. Simple configurations are indeed very easy to set-up.

My feeling is that, as with any GUI, it usually trades user-friendly with expressiveness. So while I could configure most of the things I wanted from the UI, it did not support my home network topology fully.

Initially, I had a DMZ vs Home-LAN configuration, with the Askozia box in the DMZ. Because the separation between the DMZ and the Home-LAN was through the router, it considered all the IP phones (in the Home-LAN) on the other side of the NAT, so things did not work properly.

After moving the appliance to the same LAN as the IP phones things started working properly. Normally under Asterisk this would be solved through the "localnets" settings. The UI obviously did not expose this setting.

Next time I will try to use the [Integrator Panel](http://askozia.com/handbook/index.php?title=Help_for_Integrators "Askozia Handbook: Integrator Panel") as it is supposed to expose the Asterisk configuration files directly.
