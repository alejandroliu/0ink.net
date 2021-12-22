---
title: android development
date: 2017-06-24
tags: android, java, manager, sudo, tools
revised: 2021-12-22
---

Android devs


# Install JAVA

```
yum install java-1.8.0-openjdk java-1.8.0-openjdk-devel
```

# Install SDK Tools:


Download the sdk-tools zip from [here](https://developer.android.com/studio/index.html#download)

```
mkdir /opt/android
cd /opt/android
```

The sdk should go under `/opt/android/tools`

```
unzip sdk-tools.zip
sudo chmod a+x $(sudo find . -type f -executable )
```

Create a `/etc/profile.d` or just modify `PATH` directly

```
ANDROID_HOME=/opt/android
$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools
```

Then run:

```
sudo /opt/android/tools/bin/sdkmanager tools
```

This refreshes the tools and makes sure some basic stuff is there.

# SDK Manager packages

```
sdkmanager --list
```

TO check the list and install (use sudo...)

```
build-tools;<version>
platforms;android-<version>
 'system-images;android-19;google_apis;x86'
```

Install latest, and others as required

This is needed by cordova and some applications:

## Gradle

Choose binary only [releases](https://gradle.org/releases)

```
cd /opt
unzip gradle-bin.zip
ln -s gradle-<version> gradle
```
Add gradle bin to `PATH`

When creating AVDs need to tweak config.ini (inside $HOME/.android/avd/<name>.avd

```
hw.gpu.enabled=yes
hw.gpu.mode=host
```

* * *

# CORDOVA INSTALL

```
sudo yum install nodejs npm (From EPEL)
sudo npm install -g cordova
sudo npm install -g typescript (Optional)
```
