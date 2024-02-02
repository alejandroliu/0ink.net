---
title: Home Assistant HTTP Based Authentication Backend
tags: authentication, configuration, directory
---
This recipe is to authenticate users using a web server providing
[Basic HTTP authentication](https://en.wikipedia.org/wiki/Basic_access_authentication)
for it users.

This is useful if you want to consolidate users/passwords in a single
system.  So instead of managing users on [Home Assistant][ha] you can
have all users managed from a central location.

It uses the [Home Assistant][ha]
[command line](https://www.home-assistant.io/docs/authentication/providers/#command-line)
authentication provider and the `curl` command.

To make it work is quite simple.  Copy this script to your `/config`
directory as `curl_auth.sh`:

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/main/snippets/2022/hassio/curl_auth.sh"></script>

Add the following lines to your `configure.yaml`:

```yaml
homeassistant:
  auth_providers:
    - type: command_line
      command: /config/curl_auth.sh
      args: [ "http://your-web-site-url/" ]
      meta: true
```

Make sure that you modify the URL in the configuration to a
web server that is doing Basic HTTP authentication.  It uses `curl`
for checking URLs, so `http` and `https` protocols would work.

If using `https` with self-signed certificates, you need to pass the
`-k` option which is then passed to `curl`.  See
[curl(1)](https://man7.org/linux/man-pages/man1/curl.1.html).

Example:

```yaml
args: [ "-k", "https://your-web-site-url/" ]
```

  [ha]: https://www.home-assistant.io/
