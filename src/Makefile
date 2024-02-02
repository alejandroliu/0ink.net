BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/../docs
NACOWIKI_VER=3.2.2-rel
NACOWIKI_URL=https://github.com/iliu-net/NacoWiki/archive/refs/tags/$(NACOWIKI_VER).tar.gz

help:
	@echo 'Usage;'
	@echo '   make html : (re)generate web site'
	@echo '   make serve: serve site'
	@echo '   make setup : Download dependancies'
	@echo ''

setup:
	type composer || ( echo composer needs to be installed ; exit 1)
	[ ! -d NacoWiki ] && (( wget -O- $(NACOWIKI_URL) | tar -zxf - && \
		rm -f NacoWiki && \
		ln -s NacoWiki-$(NACOWIKI_VER) NacoWiki && \
		( cd NacoWiki && composer install ) ) || \
		( rm -rf NacoWiki NacoWiki-$(NACOWIKI_VER) ; exit 1)) || :
	sed  -i~ \
		-e 's!\(file_store.\).*!\1 => "$(INPUTDIR)",!' \
		NacoWiki/web/albatros.php

html:
	php NacoWiki/web/albatros.php bloggen \
			--output=$(OUTPUTDIR)

clean:
	[ ! -d "$(OUTPUTDIR)" ] || rm -rf "$(OUTPUTDIR)"

serve:
	php NacoWiki/web/albatros.php serve \
			--output=$(OUTPUTDIR)

.PHONY: html help clean serve setup
