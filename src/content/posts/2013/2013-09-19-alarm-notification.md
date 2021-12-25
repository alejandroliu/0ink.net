---
ID: "678"
post_author: "2"
post_date: "2013-09-19 12:44:24"
post_date_gmt: "2013-09-19 12:44:24"
post_title: Alarm Notification
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: alarm-notification
to_ping: ""
pinged: ""
post_modified: "2013-09-19 12:44:24"
post_modified_gmt: "2013-09-19 12:44:24"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=678
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Alarm Notification
tags: device, information, manager
---

This tutorial describes how to use the alarm manager to set alarms and how to use the notification framework to display them. In short, the sequence goes like this:

1.  In an Activity AlarmManager.set is called with a PendingIntent containing a Uri.
2.  When the alarm goes off, the Uri is called triggering a BroadcastReceiver.
3.  In the BroadcastReceiver NotificationManager.notify is called with a PendingIntent.
4.  When the notification is clicked, the Activity in the PendingIntent is started.

# Alarm Manager

The Alarm Manager is a SystemService so it should be gotten like this

```
AlarmManager am = (AlarmManager) getSystemService(Context.ALARM_SERVICE);

```

It's set method can take parameters to define when, how and what to set off for the alarm. To set an absolute time and have it go off even if the device is on stand-by, use the `RTC_WAKEUP` type. The PendingIntent parameter is what gets called when the alarm goes off. Unless you want an Activity to start when the alarm goes off, a broadcast-type intent should be used like this

```
PendingIntent pendingintent = PendingIntent.getBroadcast(Activity.this, 0, intent, Intent.FLAG_GRANT_READ_URI_PERMISSION);

```

The intent parameter can hold a Uri which can contain some information about what the alarm is all about.

# BroadcastReceiver and NotificationManager

The BroadcastReceiver must be defined in the manifest.xml like this

```
    <receiver
        android:name="package.AlarmReceiver"
    >
        <intent-filter>
            <action
                android:name="intentname" />
            <data
                android:scheme="myscheme" />
        </intent-filter>
    </receiver>

```

The intentname and myscheme values must match the name used in the intent and the scheme used in the uri in the intent. In the onReceive method, the notification is started to show the user the alarm went off. The Notification Manager is also a SystemService, get it like this

```
NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

```

Create a new Notification object with an icon, a title and the time (probably `System.currentTimeMillis()`) Set some flags into the defaults like this

```
notification.defaults |= Notification.DEFAULT_SOUND;
notification.defaults |= Notification.DEFAULT_VIBRATE;

```

Use the `setLatestEventInfo` method to set another PendingIntent into the notification. The Activity in this intent will be called when the user clicks the notification. Again you can include a Uri into the intent to pass data to the Activity about which notification was clicked. Finally, be sure to use a unique id when calling the Notification managers notify method to actually fire the notification.

# Activity

When the user has clicked the notification is it probably safe to remove it. In the Activity which gets called by the notification, a call to the NotificationManagers cancel can be used to do this. The id which was used to fire the notification in the BroadcastReceiver will let the system know which notification to remove.

# Reloading

Android's Alarm Manager does not remember alarms when the device reboots. In order to restore the alarms you need to take these steps:

1.  In the Activity which sets the alarms, also save information about each alarm into a database.
2.  Create an additional BroadcastReceiver which gets called at boot-up to re-install the alarms.

Add the `android.permission.RECEIVE_BOOT_COMPLETED` uses-permission and the following receiver to the manifest.xml

```
    <receiver
        android:name="package.AlarmSetter"
    >
        <intent-filter>
            <action
                android:name="android.intent.action.BOOT_COMPLETED" />
        </intent-filter>
    </receiver>

```

In the onReceive method, read the database and re-install the alarms in the same way as was done at the top.

# Proximity Alerts

A similar mechanism can be used for proximity alerts. The LocationManager will fire an alert which is nearly identical to an alarm. The same mechanism to restore alerts can be used after rebooting the device.
