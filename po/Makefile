LANGS = fr_FR
MKDIR = mkdir -p
CP=cp
MV=mv
INSTALL = @INSTALL@
INSTALL_PROGRAM = @INSTALL_PROGRAM@
INSTALL_DATA = @INSTALL_DATA@
prefix        = /usr/local
localedir     = $(prefix)/share/locale

all:
static:

## Refresh all translations by extracting the strings from the current sources
refresh:
	./build_skeleton.pl > gtkada.pot
	${foreach lang,${LANGS}, \
	if [ -f ${lang}.po ]; then true; else ${CP} gtkada.pot ${lang}.po; fi; \
	msgmerge --no-wrap --update ${lang}.po gtkada.pot}

## Install the translation files
$(LANGS): 
	-msgfmt -o $@.gmo $@.po --statistics --check-header --check-format --check-domain
	$(MKDIR) $(localedir)/$@/LC_MESSAGES
	-$(INSTALL_DATA) $@.gmo $(localedir)/$@/LC_MESSAGES/gtkada.mo

install: $(LANGS)

clean:
	-$(RM) *.gmo 
	
mostlyclean: clean

distclean: mostlyclean
	-$(RM) Makefile

maintainer-clean: distclean
