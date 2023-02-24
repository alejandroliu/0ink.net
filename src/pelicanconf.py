#!/usr/bin/python3
# -*- coding: utf-8 -*- #

AUTHOR = 'Alejandro Liu'
SITENAME = '0ink.net'
SITESUBTITLE = 'Not the site you are looking for...'
SITEURL = ''

PATH = 'content'

TIMEZONE = 'Europe/Amsterdam'

DEFAULT_LANG = 'en'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = (
          ('sitemap','/sitemap.html'),
          ('Tags','/tags.html'),
          ('Repo','https://github.com/alejandroliu/0ink.net'),
          ('Wiki','https://home.0ink.net/nanowiki/'),
        )
LOGO_IMG = '/images/2021/0ink.png'
DISPLAY_PAGES_ON_MENU = True

# Social widget
SOCIAL = (
          ('github','https://github.com/alejandroliu/'),
          ('LinkedIn','https://www.linkedin.com/in/alejandro-liu-ly/'),
         )

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True

STATIC_PATHS = [
    'images',
    'extras',
]
EXTRA_PATH_METADATA = {
    'extras/favicon.ico': {'path': 'favicon.ico'},  # and this
    'extras/CNAME': {'path': 'CNAME'},
    'extras/robots.txt': {'path': 'robots.txt'},
}
FILENAME_METADATA = '(?P<date>\d{4}-\d{2}-\d{2})-(?P<postname>.*)'

SLUGIFY_SOURCE = 'basename'
ARTICLE_URL = 'posts/{date:%Y}/{slug}.html'
ARTICLE_SAVE_AS = 'posts/{date:%Y}/{slug}.html'
PAGE_URL = 'pages/{slug}.html'
PAGE_SAVE_AS = 'pages/{slug}.html'
CATEGORY_URL = 'category/c{slug}.html'
CATEGORY_SAVE_AS = 'category/c{slug}.html'

WITH_FUTURE_DATES = False

# Generate feeds:
FEED_ALL_ATOM = 'feeds/atom.xml'
FEED_ALL_RSS = 'feeds/rss.xml'

# Pagination
DEFAULT_PAGINATION = 20

THEME = 'themes/pelican-simplegrey'
# ~ THEME = 'pelican-themes/pelican-sober' # Maybe

SEARCH_SITE="0ink.net"
SEARCH_PREFILL="Search with DuckDuckGo"

# ~ PLUGINS=['liquid_tags']
PLUGINS=['filetime_from_git']
PLUGIN_PATHS = [ 'plugins' ]

# Markdown configs...

# ~ import markdown_del_ins

MARKDOWN = {
    'extension_configs': {
        # Needed for code syntax highlighting
        'markdown.extensions.codehilite': {
            'css_class': 'highlight'
        },
        'markdown.extensions.extra': {},
        'markdown.extensions.meta': {},
        # This is for enabling the TOC generation
        'markdown.extensions.toc': {
            'title': 'Table of Contents',
        },
        'markdown_mytags': {},
        'mdx_headdown': {
            'offset': 1,
        },
        'markdown_blockdiag': {
          'format': 'svg',
        },
        'markdown_aafigure': {
          'tag_type': 'inline_svg',
        },
        'markdown_svgbob': {
          'tag_type': 'inline_svg',
        },
        'mdx_include': {
          'base_path': 'include',
        },
        'mdx_graphviz': {},
        'mdx_vars': {
          'vars': {
            'SNIPPETS': 'https://github.com/alejandroliu/0ink.net/tree/master/snippets',
          },
        },
        'mdx_truly_sane_lists': {
          'nested_indent': 2,
          'truly_sane': True,
        }

    },
    'output_format': 'html5',
}
