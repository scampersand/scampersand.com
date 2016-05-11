resume.html: resume-AronGriffis.html resume.xsl Makefile
	xsltproc --html resume.xsl $< | \
	    sed 's/. 603.732.2485//' | \
	    tidy -q -i -utf8 > $@ || \
	    { status=$$?; rm -f $@; exit $$status; }

%.html: %.odt
	unoconv --doctype=document --format=html $<
