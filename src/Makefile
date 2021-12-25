PY?=python3
PELICAN?=pelican
PELICANOPTS=

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/../docs
CONFFILE=$(BASEDIR)/pelicanconf.py
PUBLISHCONF=$(BASEDIR)/publishconf.py


DEBUG ?= 0
ifeq ($(DEBUG), 1)
	PELICANOPTS += -D
endif

RELATIVE ?= 0
ifeq ($(RELATIVE), 1)
	PELICANOPTS += --relative-urls
endif

SERVER ?= "0.0.0.0"

PORT ?= 0
ifneq ($(PORT), 0)
	PELICANOPTS += -p $(PORT)
endif


help:
	@echo 'Makefile for a pelican Web site                                           '
	@echo '                                                                          '
	@echo 'Usage:                                                                    '
	@echo '   make html                           (re)generate the web site          '
	@echo '   make clean                          remove the generated files         '
	@echo '   make regenerate                     regenerate files upon modification '
	@echo '   make serve [PORT=8000]              serve site at http://localhost:8000'
	@echo '   make devserver [PORT=8000]          serve and regenerate together      '
	@echo '   make setup                          Set-up venv                        '
	@echo '                                                                          '
	@echo 'Set the DEBUG variable to 1 to enable debugging, e.g. make DEBUG=1 html   '
	@echo 'Set the RELATIVE variable to 1 to enable relative urls                    '
	@echo '                                                                          '

html:
	python3 hax.py --tags=tagcloud $(INPUTDIR)/pages/*.md $(INPUTDIR)/posts/*/*.md
#~ 	[ -d $$(pwd)/.venv ] || ( python3 -m venv --system-site-packages $$(pwd)/.venv ; \
#~ 	  .  $$(pwd)/.venv/bin/activate ; \
#~ 	  pip install pelican-liquid-tags mdx_include)
#~ 	env PYTHONPATH="$$(cd .venv/lib/python*/site-packages && pwd)" \
#~ 	  "$(PELICAN)" "$(INPUTDIR)" -o "$(OUTPUTDIR)" -s "$(CONFFILE)" $(PELICANOPTS)
	"$(PELICAN)" "$(INPUTDIR)" -o "$(OUTPUTDIR)" -s "$(CONFFILE)" $(PELICANOPTS)
	python3 sitemap.py --strip=2 --prefix=https://0ink.net/ --xml=$(OUTPUTDIR)/sitemap.xml --html=$(OUTPUTDIR)/sitemap.html ../docs/pages/*.html ../docs/posts/*/*.html
	# Fix links in site feeds...
	sed -i -e 's!<link>/!<link>https://0ink.net/!g' "$(OUTPUTDIR)/feeds/rss.xml"
	sed -i -e 's!<link href="/!<link href="https://0ink.net/!g' "$(OUTPUTDIR)/feeds/atom.xml"
	> $(OUTPUTDIR)/.nojekyll

clean:
	[ ! -d "$(OUTPUTDIR)" ] || rm -rf "$(OUTPUTDIR)"

regenerate:
	"$(PELICAN)" -r "$(INPUTDIR)" -o "$(OUTPUTDIR)" -s "$(CONFFILE)" $(PELICANOPTS)

serve:
	"$(PELICAN)" -l "$(INPUTDIR)" -o "$(OUTPUTDIR)" -s "$(CONFFILE)" $(PELICANOPTS)

devserver:
	"$(PELICAN)" -lr "$(INPUTDIR)" -o "$(OUTPUTDIR)" -s "$(CONFFILE)" $(PELICANOPTS)

setup:
	@echo 'TODO'


.PHONY: html help clean regenerate serve devserver setup
