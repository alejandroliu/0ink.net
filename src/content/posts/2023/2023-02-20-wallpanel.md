---
title: Home Assistant Wall Panel
---
For a while I was using [TabletClock][tc] with old tablets.  But 
this has not been updated in a while.  I was thinking of writing my
own version until I found [WallPanel][wpa].

Essentially it is purposely built web-browser with special features which makes it
possible to use it to replaces [TabletClock][tc].  Essentially, I could
replace [TabletClock][tc] with a web-page showing the time and a weather
forecast and have [WallPanel][wpa] point to it.  Easy and simple, and can be 
customized in multiple ways.

Currently I am using [WallPanel][wpa] with [HomeAssistant][ha].  I am using 
these features:

- Date/time screen saver with auto off by face recognition
- Web Cam functionality

I normally have it on a [HomeAssistant][ha] panel showing time, weather forecaset
and a few choice controls.

![panel]({static}/images/2023/wallpanel.png)



[tc]: https://github.com/HyperTechnology5/TabletClock
[wpa]: https://github.com/thecowan/wallpanel-android
[ha]: https://www.home-assistant.io/
