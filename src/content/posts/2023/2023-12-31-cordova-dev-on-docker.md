---
title: Cordova devlopment on docker
---
- [docker hub: cordova](https://hub.docker.com/r/beevelop/cordova)
- [docker hub: android cordova](https://hub.docker.com/r/vgaidarji/docker-android-cordova/)
- [docker hub: webration cordova](https://hub.docker.com/r/webratio/cordova)
- [docker hub: alpine cordova](https://hub.docker.com/r/cakuki/alpine-cordova/)

***

- https://cordova.apache.org/docs/en/latest/guide/platforms/ios/index.html
- https://hub.docker.com/r/walterwhites/docker-cordova
  - https://github.com/walterwhites/docker-cordova
- https://github.com/hamdifourati/cordova-android-builder
- https://swaminathanvetri.in/2016/12/24/building-cordova-apps-using-docker-images/
- https://medium.com/@cnadeau_/docker-as-a-cordova-android-application-builder-9e292298c08e
- https://www.linux-magazine.com/Issues/2018/215/Tutorials-Docker/(offset)/3


Docker is each day a more powerful and useful tool, in this case,
it was used to build a Cordova app.

After trying some docker images, the one that worked was:

https://hub.docker.com/r/walterwhites/cordova

run in mounting the local folder where the project is into
container src folder

```bash
docker run -ti -v ${PWD}:/src walterwhites/cordova
```

After running it some issues appeared, but there is a solution mentioned
on the docs:

"You have not accepted the license agreements of the following SDK
components" when you build your app, you need to accept licenses"

You just follow the steps, and it works.

Then to build the cordova app you run:

# dev / debug

```bash
cordova build android
```

# release

```bash
cordova build android --release
```

To change the name of the output file, you can edit the
`/platforms/android/app/gradle.build`
file, and add inside the android default configs the following line:

```java
setProperty("archivesBaseName", "your-app-name-V-"+privateHelpers.extractStringFromManifest("versionCode"))
```
 
In this case, the version code is added to the file name.
 
And that´s it!
 
If for any reason you get the weird error
 
```
"Error: Cannot find module 'q'"
```

Try to remove and add the android platform again:

```bash
cordova platform remove android
cordova platform add android
```
