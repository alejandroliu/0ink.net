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
- Added custom `markdown_mytags` markdown extension.  Features:
  - ~~del~~
  - ++ins++
  - ??mark??
  - ^^superscript^^
  - ,,subscript,,
  - [ ] checklists
- mdx_vars: lets you do variable substitutions: ${var_name}
- [markdown include](https://github.com/neurobin/mdx_include)
- [blockdiag](https://github.com/gisce/markdown-blockdiag)
- [aafigure](https://github.com/mbarkhau/markdown-aafigure)
- [svgbob](https://github.com/mbarkhau/markdown-svgbob)
- [truly_sane_lists](https://github.com/radude/mdx_truly_sane_lists)
- graphviz

# known issues or non-issues

- Adding pelican plugins:
  - [liquid_tags](https://github.com/pelican-plugins/liquid-tags) :
    no.
  - [graphviz](https://github.com/pelican-plugins/graphviz) :
    note that `liquid_tags` does some of this already.
- Enable plugins
  - python3 -m venv --system-site-packages $(pwd)/.venv
  - . .venv/bin/activate
  - pip install ... plugins ...
  - python3 /usr/bin/pelican-plugins -l


# TODO

- Add Title's from header to the tokenizer candidate
- gh-actions integration:
  - https://github.com/marketplace/actions/github-pages-action
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



