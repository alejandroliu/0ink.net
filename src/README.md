# README

- hax.py : Script that reads posts/pages and updates its
  meta-data headers.  It does autotagging based on the
  tagcloud file.
- tagcloud : contains list of words to check for auto tagging.
  Note, it accepts entries like:
  - {something}={tag}
- this is used to have multiple matches to the same tag as to
  improve tag counts.
- [filetime from git](https://github.com/getpelican/pelican-plugins/tree/master/filetime_from_git):
  - this has been tweaked so that posts can also contain `date` or
    `filemeta_data` dates.

# known issues or non-issues

- Installing pelican-plugins and markdown extensions is
  a bit wonky but it seems to work.
- Adding pelican plugins:
  - [shortcodes](https://github.com/getpelican/pelican-plugins/tree/master/shortcodes)
  - [optimize images](https://github.com/getpelican/pelican-plugins/tree/master/optimize_images)
  - [liquid_tags](https://github.com/pelican-plugins/liquid-tags)
  - [graphviz](https://github.com/pelican-plugins/graphviz) :
    note that `liquid_tags` does some of this already.
- Adding markdown extensions:
  - [markdown include](https://github.com/neurobin/mdx_include)
  - [blockdiag](https://github.com/gisce/markdown-blockdiag)
  - [aafigure](https://github.com/mbarkhau/markdown-aafigure)
  - [svgbob](https://github.com/mbarkhau/markdown-svgbob)
  - [mermaid](https://github.com/oruelle/md_mermaid)
  - [list of markdown extensions](https://python-markdown.github.io/extensions/)

# TODO

- Make sure internal links are properly set-up
- Feature
  - shortcodes
  - ascii graphics

- Post processing posts
  - $txt$ -> <expansion>
  - <code:embed="/snippets/">
  - <code:embed="http">
  - convert to <pre> blocks with syntax highlighter
  -  xbps-query -Rs highlight
- ? create SVG from <pre> sections
  - https://github.com/blampe/goat
- Add priority to sitemap.xml based on age of articles:
  - 0.8 - 1.0 : home page, product info, landing pages
  - 0.4 - 0.7 : articles, blogs, faqs, etc
  - 0.0 - 0.3 : outdated info or old news
- mappings based on dates...
  - guideline
    - older than 3 years, prio 0.2
    - current year articles, prio 0.6, other articles 0.5
  - we add a header into the article and we use that, otherwise
    we use the modified date.

- Enable plugins
  - python3 -m venv --system-site-packages $(pwd)/.venv
  - . .venv/bin/activate
  - pip install ... plugins ...
  - python3 /usr/bin/pelican-plugins -l


```
export PYTHONPATH=$(pwd)/.venv/lib/python3.10/site-packages
py -m venv --system-site-packages .venv
( . .venv/bin/activate ; pip install ???)
```
