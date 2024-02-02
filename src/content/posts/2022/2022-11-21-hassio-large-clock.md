---
title: Home Assistant Large Clock
tags: directory
---
This recipe is my version of providing a "large clock" face in the
[home assistant][ha] dashboard.

Enable serving local static files:

- Create directory `www` in your `config` directory.
- Restart [home assistant][ha].
- Static files are now available as `http://homeassistant.local:8123/local/`.

Place the HTML with your clock in a file i.e. `$config/www/clock.html`.
I am using this:

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/main/snippets/2022/hassio/clock.html"></script>

Then add a [webpage](https://www.home-assistant.io/dashboards/iframe/) card:

```yaml
type: iframe
url: /local/clock.html
aspect_ratio: 45%
```

Obviously you can fully exercise your HTML to get your clock to look
exactly like you want.

I wrote this because I couldn't get the
[markdown](https://www.home-assistant.io/dashboards/markdown/) card
to style properly.  Also, I wasn't keen on installing the
[time and date](https://www.home-assistant.io/integrations/time_date/)
sensor which is required for the clock examples based on the
[picture elements](https://www.home-assistant.io/dashboards/picture-elements/)
card.

Other implementations:

- https://community.home-assistant.io/t/really-simple-big-clock/255971
- https://community.home-assistant.io/t/just-a-big-clock/69976/2


  [ha]: https://home-assistant.io/
