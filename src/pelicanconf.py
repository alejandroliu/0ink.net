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
          ('Repo','https://github.com/alejandroliu/0ink.net'),
          ('Alejandro','https://alejandro.iliu.net/'),
          ('Tags','/tags.html'),
          ('sitemap','/sitemap.html'),
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
}

SLUGIFY_SOURCE = 'basename'
ARTICLE_URL = 'posts/{date:%Y}/{slug}.html'
ARTICLE_SAVE_AS = 'posts/{date:%Y}/{slug}.html'
PAGE_URL = 'pages/{slug}.html'
PAGE_SAVE_AS = 'pages/{slug}.html'
CATEGORY_URL = 'category/c{slug}.html'
CATEGORY_SAVE_AS = 'category/c{slug}.html'

WITH_FUTURE_DATES = False

# Pagination
DEFAULT_PAGINATION = 20

THEME = 'themes/pelican-simplegrey'

# ~ THEME = 'pelican-themes/gum' # styling is a little off
# ~ THEME = 'pelican-themes/Just-Read' # nav is wacked
# ~ THEME = 'pelican-themes/pelican-sober' # Maybe

SEARCH_SITE="0ink.net"
SEARCH_PREFILL="Search with DuckDuckGo"

