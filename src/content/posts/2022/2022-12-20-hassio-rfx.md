---
title: Home Assistant RFXCOM Integration
tags: configuration, integration
---
## RFXCOM RFXtrx


[This](https://www.home-assistant.io/integrations/rfxtrx/) integration is
to control RFXtrx devices.  I am using to control Somfy blinds and KlikAanKlikUit
remotes.

- Add integration: `RFXCOM RFXtrx`
- Conection type: `Serial`
- Select device: `RFXtrx433XL - RFXtrx433XL, s/n: * - RFXCOM`

Remember to configure the RFXCOM unit **before** using it with [Home Assistant][ha]
as [Home Assistant][ha] integration has limited control of it.

Specifically, you need to use the RFXCOM [rfxmngr](http://www.rfxcom.com/downloads.htm)
tool to enable the relevant protocols and in the case of Somfy blinds, pair them.

For my home I enabled the `AC` protocol for use with
[KAKU](https://klikaanklikuit.nl/) devices.

### KlikAanKlikUit

[KAKU](https://klikaanklikuit.nl/) are inexpensive home automation devices that
use a wireless protocol very similar to X-10.

The simplest way is to:

- List integrations
- Configure `RFXTRX`
- Enable Automatic Add
- Submit

Afterwards, just use the lights and devices, and they will be added automatically.


# Somfy

For pairing the Somfy blinds, you can refer to [this article](https://www.vlieshout.net/home-assistant-and-somfy-rts-with-rfxcom/)
and [ths one](https://www.vesternet.com/en-eu/pages/apnt-79-controlling-somfy-rts-blinds-with-the-rfxtrx433e).

In my configuration I am using:

```
remoteID: 010E1 >  0 : 10 : E1 : 010E1
          123456
          ABCDEF
remoteID: 69121  > 0 : 16 : 225 : 4321
unitCode: 01

1234567890123456
071a000000000000
071a00000010e101
```

***


# Tweaks

Because for some reason my Skylight cover says "Open" when is "Closed" and
viceversa.

To clean that up we use the:

- https://www.home-assistant.io/integrations/cover.template/
- https://www.home-assistant.io/integrations/cover/

To create a "template" cover that shows things properly.  In `configuration.yaml`
we have this:

```yaml
cover:
  - platform: template
    covers:
      study_skylight_p:
        unique_id: 13d7a089-c536-4dc0-b2c0-e5dae6521460
        open_cover:
          service: cover.close_cover
          target:
            entity_id: cover.rfy_0010e1_1
        close_cover:
          service: cover.open_cover
          target:
            entity_id: cover.rfy_0010e1_1
        stop_cover:
          service: cover.stop_cover
          target:
            entity_id: cover.rfy_0010e1_1

```

  [ha]: https://www.home-assistant.io/
 