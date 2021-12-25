---
ID: "1016"
post_author: "2"
post_date: "2016-12-11 12:38:51"
post_date_gmt: "2016-12-11 12:38:51"
post_title: Building Signed APKs
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: building-signed-apks
to_ping: ""
pinged: ""
post_modified: "2016-12-11 12:38:51"
post_modified_gmt: "2016-12-11 12:38:51"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=1016
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Building Signed APKs
tags: android
---

Building signed APK's for Android is easy if you know what you
are doing.

This article goes over the preparation steps and the additional
build instructions needed to created signed APKs.

## Preparation

First you need to have a `keystore`.  Use this command:

```bash
#!/bin/bash
keystore_file="my_key_store.keystore"
key_name="john_doe"
secret='fake_password'
name='John Doe'
dept='Engineering'
org='TLabs Inc'
place='New York'
province='NY'
country='US'

keytool -genkey -v -keystore "$keystore_file" -alias "key_name" -keyalg "RSA" -validity 10000 -storepass "$secret" -keypass "$secret" &lt;&lt;EOF
$name
$dept
$org
$place
$province
$country
yes
EOF

```

Remember the keystore file and passwords.

## Build instructions

In your `build.gradle` you need the following:

```javascript

android {
  signingConfigs {
    release {
      storeFile file("my_keystore.keystore")
      storePassword "{password}"
      keyAlias "Key_Alias"
      keyPassword "{password}"
    }
  }
  buildTypes {
    release {
      signingConfig signingConfigs.release
    }
  }
}


```



