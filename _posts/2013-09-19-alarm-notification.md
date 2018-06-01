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
...
---

This tutorial describes how to use the alarm manager to set alarms and how to use the notification framework to display them.

In short, the sequence goes like this:

<ol>
<li>In an Activity AlarmManager.set is called with a PendingIntent containing a Uri.</li>
<li>When the alarm goes off, the Uri is called triggering a BroadcastReceiver.</li>
<li>In the BroadcastReceiver NotificationManager.notify is called with a PendingIntent.</li>
<li>When the notification is clicked, the Activity in the PendingIntent is started.</li>
</ol>

<h1>Alarm Manager</h1>

The Alarm Manager is a SystemService so it should be gotten like this

<pre><code>AlarmManager am = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
</code></pre>

It's set method can take parameters to define when, how and what to set off for the alarm.

To set an absolute time and have it go off even if the device is on stand-by, use the <code>RTC_WAKEUP</code> type.

The PendingIntent parameter is what gets called when the alarm goes off.

Unless you want an Activity to start when the alarm goes off, a broadcast-type intent should be used like this

<pre><code>PendingIntent pendingintent = PendingIntent.getBroadcast(Activity.this, 0, intent, Intent.FLAG_GRANT_READ_URI_PERMISSION);
</code></pre>

The intent parameter can hold a Uri which can contain some information about what the alarm is all about.

<h1>BroadcastReceiver and NotificationManager</h1>

The BroadcastReceiver must be defined in the manifest.xml like this

<pre><code>    &lt;receiver
        android:name="package.AlarmReceiver"
    &gt;
        &lt;intent-filter&gt;
            &lt;action
                android:name="intentname" /&gt;
            &lt;data
                android:scheme="myscheme" /&gt;
        &lt;/intent-filter&gt;
    &lt;/receiver&gt;
</code></pre>

The intentname and myscheme values must match the name used in the intent and the scheme used in the uri in the intent.

In the onReceive method, the notification is started to show the user the alarm went off.
The Notification Manager is also a SystemService, get it like this

<pre><code>NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
</code></pre>

Create a new Notification object with an icon, a title and the time (probably <code>System.currentTimeMillis()</code>)

Set some flags into the defaults like this

<pre><code>notification.defaults |= Notification.DEFAULT_SOUND;
notification.defaults |= Notification.DEFAULT_VIBRATE;
</code></pre>

Use the <code>setLatestEventInfo</code> method to set another PendingIntent into the notification.

The Activity in this intent will be called when the user clicks the notification.

Again you can include a Uri into the intent to pass data to the Activity about which notification was clicked.

Finally, be sure to use a unique id when calling the Notification managers notify method to actually fire the notification.

<h1>Activity</h1>

When the user has clicked the notification is it probably safe to remove it.

In the Activity which gets called by the notification, a call to the NotificationManagers cancel can be used to do this.

The id which was used to fire the notification in the BroadcastReceiver will let the system know which notification to remove.

<h1>Reloading</h1>

Android's Alarm Manager does not remember alarms when the device reboots.
In order to restore the alarms you need to take these steps:

<ol>
<li>In the Activity which sets the alarms, also save information about each alarm into a database.</li>
<li>Create an additional BroadcastReceiver which gets called at boot-up to re-install the alarms.</li>
</ol>

Add the <code>android.permission.RECEIVE_BOOT_COMPLETED</code> uses-permission and the following receiver to the manifest.xml

<pre><code>    &lt;receiver
        android:name="package.AlarmSetter"
    &gt;
        &lt;intent-filter&gt;
            &lt;action
                android:name="android.intent.action.BOOT_COMPLETED" /&gt;
        &lt;/intent-filter&gt;
    &lt;/receiver&gt;
</code></pre>

In the onReceive method, read the database and re-install the alarms in the same way as was done at the top.

<h1>Proximity Alerts</h1>

A similar mechanism can be used for proximity alerts.
The LocationManager will fire an alert which is nearly identical to an alarm.
The same mechanism to restore alerts can be used after rebooting the device.

