WML_LIB=/usr/lib/wml/exec
CIBLE=HP-HOWTO
DESTDIR=/www/hyper-linux.org/$(CIBLE)
VER=v0.96
RH=/usr/src/redhat

.EXPORT_ALL_VARIABLES:

all: Makefile.fr Makefile.en
	if [ ! -d images ]; then ln -sf ../images ; fi
	./checkFREN $(CIBLE).sgml
	echo -n "<!ENTITY curdate \"" > curdate.sgml
	echo -n `date +"%Y-%m-%d"` >> curdate.sgml
	echo "\">" >> curdate.sgml
	make -f Makefile.fr all
	make -f Makefile.en all
	
test: Makefile.fr Makefile.en
	make -f Makefile.fr test
	make -f Makefile.en test

all-rtf: Makefile.fr Makefile.en
	make -f Makefile.fr all-rtf
	make -f Makefile.en all-rtf
	
clean: Makefile.fr Makefile.en
	if [ ! -d images ]; then ln -sf ../images ; fi
	make -f Makefile.fr clean
	make -f Makefile.en clean
#	rm -f images/netcraft.gif images/netcraft.png
#	lynx -dump http://www.netcraft.com/survey/Reports/current/overallc.gif > images/netcraft.gif
	rm -f version.sgml
	echo "<!ENTITY curver \"$(VER)\">" > version.sgml

install: web
	
web: all
	rm -rf $(DESTDIR)/$(VER) $(DESTDIR)/current
	mkdir $(DESTDIR)/$(VER)
	cp $(CIBLE).dsl $(CIBLE).sgml $(CIBLE).spec Makefile Makefile.src $(DESTDIR)/$(VER)
	(cd .. ; cp -a mirror images $(DESTDIR))
	make -f Makefile.fr web
	make -f Makefile.en web
	find $(DESTDIR) -type f -exec chmod 644 {} \;
	find $(DESTDIR) -type d -exec chmod 755 {} \;
	ln -sf $(DESTDIR)/$(VER) $(DESTDIR)/current
	
rpm: all
	make -f Makefile.fr rpm
	make -f Makefile.en rpm
	ln -sf $(RH)/SRPMS/$(CIBLE).fr-$(VER)-1.src.rpm .
	ln -sf $(RH)/SRPMS/$(CIBLE).en-$(VER)-1.src.rpm .
	
Makefile.en: Makefile.src
	$(WML_LIB)/wml_p9_slice -o ENuUNDEF:Makefile.en Makefile.src

Makefile.fr: Makefile.src
	$(WML_LIB)/wml_p9_slice -o FRuUNDEF:Makefile.fr Makefile.src

livhp: all
	zip -v $(CIBLE)-$(VER).zip *.pdf
	echo "Here is the new HP-HOWTO/Voici la nouvelle version du HP-HOWTO" | mutt bc -c bruno -a $(CIBLE)-$(VER).zip -s "$(CIBLE) Version $(VER)"

LDP: all Makefile.fr
	make -f Makefile.en LDP
	make -f Makefile.fr LDP

bco: 
	echo "Sources du HP-HOWTO" | mutt bc -a Makefile.src -a Makefile -a $(CIBLE).dsl -a $(CIBLE).sgml -a $(CIBLE).spec -a annonce.EN -a annonce.FR -s "$(CIBLE) Sources Version $(VER)"

xml: Makefile.en Makefile.fr
	make -f Makefile.en xml
	make -f Makefile.fr xml

