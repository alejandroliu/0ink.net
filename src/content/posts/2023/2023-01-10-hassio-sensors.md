---
title: Home Assistant sensors
---
I finished migrating my [VeraEdge][vera] to [Home Assistant][ha].  I think after
using it for some time, I find [Home Assistant][ha] far superior to the
[VeraEdge][vera] in every way.

So, I took the time to mostly standardise my sensors which make things simpler to
manage/mantain.

As such, essentially I am only using 4 types of sensors:

- [Neo Coolcam Door/Window Sensor DS01Z](https://www.robbshop.nl/neo-coolcam-raam-deur-sensor-z-wave-plus) : 
  This is a door/window sensor.  I still have a couple of these sensors from before.
  They are EOL now, being replaced by the DS07Z.
  ![DS01Z]({static}/images/2023/sensor-ds01z.png)
- [New Coolcam Door/Window Sensor DS07Z](https://www.robbshop.nl/neo-coolcam-raam-deursensor-z-wave-plus-met-usb-voeding) :
  This is a door/window sensor with integrated temperature and humidty sensors.  I
  was standardirising to this sensor type for door/window and also for temperature
  and humidity until they became hard to source.  The last couple of sensors of 
  this type I had to buy from AliExpress.  For the moment, I have enough sensors,
  but in the future, I may need to find a new source.
  ![DS07Z]({static}/images/2023/sensor-ds07z.png)
- [Fibaro Smoke Sensor 2](https://www.robbshop.nl/fibaro-smoke-sensor-2-z-wave-plus) :
  This is a Smoke Sensor with integrated temperature meter.  I am using this
  to replace my __"dumb"__ smoke sensors.  These sensors only detect smoke
  and do **not** detect CO,,2,,.  This is not a problem because on one hand,
  these sensors are mounted on the ceiling, which is detrimental for CO,,2,,
  detection as CO,,2,, tends to accumulate on the floor first.  The other
  is that CO,,2,, detection is more important for smokeless fires (i.e. gas
  burning).  Since we are only using this for the water heater, it is less
  of a priority.
  ![Smoke Sensor]({static}/images/2023/sensor-smoke.png)
- [New Coolcam Water Leak sensor](https://www.robbshop.nl/neo-coolcam-overstromingssensor-z-wave-plus-eol) :
  This is a water leak sensor.  Unfortunately is already EOL.
  ![Water Leak Sensor]({static}/images/2023/sensor-leak.png)

I used to have other sensors types:

- Philio Tech Door/Window Sensor
- Philio Tech multi sensors
  - While these sensors were good in the sense that they paired easily with my
    [VeraEdge][vera] and gave accurate reading, they were (at least to me)
    not easy to open.  So every time I would want to replace the battery
    I would **accidentally** break the latches.
- Other door sensors
  - Also, a number of sensors that I tried, made it difficult to stock up on
    spare batteries.  Furthermore, specially for the door/window sensors,
    some had awkward shapes.




  [vera]: https://support.getvera.com/hc/en-us/articles/360021950353-Welcome-to-Vera-Getting-Started
  [ha]: https://www.home-assistant.io/