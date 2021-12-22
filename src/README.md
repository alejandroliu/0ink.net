TODO:

- modified date from git logs?
  - check logs and add them to pelican.conf extra meta data
    - EXTRA_PATH_METADATA
  - or use a pre-commit hook to update it
  - save extra meta data using base.html (before
    - {% block extra_meta %}
    - extend base.html from article etc...
- Adding extensions?
  - https://github.com/neurobin/mdx_include
  - markdown include
- Create tags automatically
  - From a tag dictionary
  - We read files and add tags to files that have that
    word
- Post processing posts
  - $txt$ -> <expansion>
  - <code:embed="/snippets/">
  - <code:embed="http">
    - convert to <pre> blocks with syntax highlighter
    -  xbps-query -Rs highlight
  - ? create SVG from <pre> sections
    - https://github.com/blampe/goat
- Add drafts stuff...
  - set metadata from folders
  - create a drafts page
- Create sitemaps
  - sitemap.xml
    - https://www.sitemaps.org/protocol.html
    - Sitemap at the root directory of your HTML server;
      http://example.com/sitemap.xml.
  - sitemap.html
  - Crawl all the \*.html files to create sitemap.
  - Read the html meta tags


