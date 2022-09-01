---
title: Photoprism
tags: application, authentication, cloud, database, library, management, network, proxy
---
[photoprism][pp] is a web based photo management application.

![photoprism preview](https://docs.photoprism.app/img/preview.jpg)

From its website:

> PhotoPrism® is an AI-Powered Photos App for the Decentralized Web.
> It makes use of the latest technologies to tag and find pictures
> automatically without getting in your way. You can run it at home,
> on a private server, or in the cloud. 

Features:

- Browse all your photos and videos without worrying about RAW conversion,
  duplicates or video formats
- search: Easily find specific pictures using powerful search filters
- places: Includes four high-resolution world maps to bring back the
  memories of your favorite trips
- Play Live Photos™ by hovering over them in albums and search results
- people: Recognizes the faces of your family and friends
- Automatic classification of pictures based on their content and location

What I found is that it does most things automatically.

My implementation:

- I use a docker instance for [photoprism][pp] linked to a `mysql` database.
  (actually `mariadb`).
  - [database setup](https://docs.photoprism.app/getting-started/advanced/databases/)
- This [photoprism][pp] instance is set as `AUTH=public`, so no authentication.
  Users on my home network can connect directly.  From the Internet, I am using an
  [nginx][nx] reverse proxy.  This reverse proxy requires authentication.
- For photo sharing, a different [photoprism][pp] instance is used pointing to the same
  file system and mysql as the main instance.  This instance however has `AUTH=password`
  enabled, so only `shared` links can be visited.
- For uploading photos from my iPhone, I am using [PhotoSync][psync].  This can be
  configured to upload directly to [photoprism][pp] using WebDav.  (See instructions for
  [syncing with mobile devices](https://docs.photoprism.app/user-guide/sync/mobile-devices/).)
  On the other hand, it is complicated for me due to permission problems in my home
  network.  For that reason, I am using a small container running a `sshd` daemon
  and I sync to that small container using `sftp` protocol.

Some issues I found:

- face recognition is a bit wonky.  Specially for kid's faces.
- some tweaks may be needed to get things to display just right.
- running using the embedded `sqlite` database won't scale beyond a handful of
  photos.
- I have a photo library of 400GB.  It took a long time to index.

Before I would copy files from my camera to my server.  In the case of
video files, a re-encoding step was needed.  With todays smartphones
this is not needed.  The smartphone can sync directly to the server
and files are already compressed with a good enough CODEC.

 [pp]: https://photoprism.app/
 [nx]: https://nginx.org/
 [psync]: https://link.photoprism.app/photosync

