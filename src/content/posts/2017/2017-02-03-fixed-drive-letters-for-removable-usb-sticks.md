---
ID: "1034"
post_author: "2"
post_date: "2017-02-03 10:30:24"
post_date_gmt: "2017-02-03 10:30:24"
post_title: Fixed drive letters for removable USB sticks
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: fixed-drive-letters-for-removable-usb-sticks
to_ping: ""
pinged: ""
post_modified: "2017-02-03 10:34:39"
post_modified_gmt: "2017-02-03 10:34:39"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=1034
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Fixed drive letters for removable USB sticks
tags: backup, drive, management, tools, windows
---


If you use multiple USB drives, you've probably noticed that the drive letter can be
different each time you plug one in. If you'd like to assign a static letter to a drive that's
the same every time you plug it in, read on.

Windows assigns drive letters to whatever type of drive is available. This can be annoying
especially if you use backup tools or portable apps that prefer to have the same drive letter
every time.

To work with drive letters, you'll use the Disk Management tool built into Windows. In Windows
7, 8, or 10, click Start, type`create and format`, and then click `Create and format hard disk
partitions.` Don't worry. You're not going to be formatting or creating anything. That's just
the Start menu entry for the Disk Management tool. This procedure works the same in pretty much
any version of Windows (though in Windows XP and Vista, you'd need to launch Disk Management
through the Administrative Tools item in the Control Panel).

![sud_1]({static}/images/2017/sud_1.png)

Windows will scan and then display all the drives connected to your PC in the Disk Management
window. Right-click the USB drive to which you want to assign a persistent drive letter and
then click `Change Drive Letter and Paths.`


![sud_2]({static}/images/2017/sud_2.png)

The `Change Drive Letter and Paths` window the selected drive's current drive letter. To
change the drive letter, click `Change.`

![sud_3]({static}/images/2017/sud_3.png)

In the `Change Drive Letter or Path` window that opens, make sure the `Assign the following
drive letter` option is selected and then use the drop-down menu to select a new drive letter.
When you're done, click `OK.`

NOTE: We suggest picking a drive letter between M and Z, because earlier drive letters may
still get assigned to drives that don't always show up in File Explorer-like optical and
removable card drives. M through Z are almost never used on most Windows systems.

![sud_4]({static}/images/2017/sud_4.png)

Windows will display a warning letting you know that some apps might rely on drive letters
to run properly. For the most part, you won't have to worry about this. But if you do have
any apps in which you've specified another drive letter for this drive, you may need to
change them. Click `Yes` to continue.

![sud_5]({static}/images/2017/sud_5.png)

Back in the main Disk Management window, you should see the new drive letter assigned to the
drive. You can now close the Disk Management window.

![sud_6]({static}/images/2017/sud_6.png)

From now on, when you disconnect and reconnect the drive, that new drive letter should persist.
You can also now use fixed paths for that drive in apps `such as back up apps` that may require them.

Source: [howtogeek](http://www.howtogeek.com/96298/assign-a-static-drive-letter-to-a-usb-drive-in-windows-7/)

