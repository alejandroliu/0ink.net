---
title: Z-Wave Associations with Home Assistant
date: "2024-10-21"
author: alex
---
[toc]
***
This is an update to [[../2019/2019-03-01-z-wave-associations-with-vera.md|Z-Wave associations with Vera UI]].

# Introduction

Z-Wave associations lets you control _slave_ devices from a _master_
device without the Z-Wave controller or Hub.

For this to really work the _master_ device sending commands must
support this functionality.  This varies from device to device,
so you must look up the documentation of the _master_ device and
find the supported associations groups.  In a nutshell, you look-up
what each association group is for, and then you add to that group
the _slave_ devices that will receive the Z-wave commands from the
_master_.

See [this article][ref1] for more information on associations.

In [Home Assistant][hassio], Z-Wave support is provided by add-ons.  There
are two add-ons available:

- [Z-Wave JS][addon] : from the official Add On store
- [Z-Wave JS UI][uiaddon] : from the  Community Add Ons

Both are based on the [Z-Wave JS][zwavejs] project.  However the [Z-Wave JS UI][uiaddon] Add On from the
Community store, exposes the [Z-Wave JS][zwavejs] control panel, where as the official [Z-Wave JS][addon]
Add on does **NOT**.

[Home assistant][hassio] by default does not expose the functionality and UI
interface to modify Z-Wave group associations.  That is why [Z-Wave JS UI][uiaddon] Add On is
required.


# Configuring associations

![addon]({static}/images/2025/zassoc/addon-lo.png)

Open the [Z-Wave JS UI][uiaddon] user interface by using the sidebar link (if enabled in the
addon settings page) or from the settings addon page, using the link **OPEN WEB UI**.

![control panel]({static}/images/2025/zassoc/menu-lo.png)

Select control panel from the tab menu.

![devinfo]({static}/images/2025/zassoc/device-grp-lo.png)

Find the _master_ device from the list of devices, and open its properties.  Click on the **GROUPS**
tab.

# Setting associations


To create a new association click on the **ADD** option.

![new]({static}/images/2025/zassoc/new-lo.png)

Complete the form:

- **Node Endpoint** : Simply select from the list.  Usually **Root Endpoint**
- **Group** : Select the group.  Usually the group refers to the event that will be used.  For
  example, it could be a button group.
- **Target Node** : Select from the list the _slave_ device that we want to control.
- **Target Endpoint** : Leave blank unless the _slave_ device has multiple controls (for example
  a double switch).

# Removing associations

Simply click on the red trashcan icon next to the association you want to delete.

# Last words

Note that some associations are always available by default and can not be changed.  These
are used to report the device state to the Z-Wave Controller/Hub.


  [addon]: https://github.com/home-assistant/addons/tree/master/zwave_js
  [uiaddon]: https://github.com/hassio-addons/addon-zwave-js-ui
  [zwavejs]: https://github.com/zwave-js
  [hassio]: https://www.home-assistant.io/
  [ref1]: https://www.vesternet.com/en-eu/pages/z-wave-groups-scenes-associations