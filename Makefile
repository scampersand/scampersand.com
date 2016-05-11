GRAVATAR = img/gravatar/perkins-cove/bright.jpg
JEKYLL_ARGS =
COMPASS_ARGS = --sass-dir site/css --css-dir public/css --images-dir img --javascripts-dir js --relative-assets
WATCH_EVENTS = create delete modify move
WATCH_DIRS = site

all: jekyll sass

production: COMPASS_ARGS += -e production
production: all

jekyll:
	jekyll build $(JEKYLL_ARGS)

sass:
	compass compile $(COMPASS_ARGS)

watch:
	trap exit 2; \
	while true; do \
	    $(MAKE) all; \
	    inotifywait $(WATCH_EVENTS:%=-e %) -r $(WATCH_DIRS); \
	done

serve:
	jekyll serve --no-watch --skip-initial-build --host 0

dev:
	$(MAKE) -j2 watch serve

dream: production
	rsync -az --exclude=.git --delete-before public/. agriffis@n01se.net:arongriffis.com/

ghp: production
	cd public && \
	git add -A && \
	( ! git status --porcelain | grep -q . || git commit -m "Deploy from agriffis/arongriffis.com" ) && \
	git push

publish: dream ghp

gravatar:
	for x in 144 114 72 57; do \
	    geom=$${x}x$${x}; \
	    img=site/apple-touch-icon-$$geom-precomposed.png; \
	    rm -f $$img; \
	    convert -scale $$geom $(GRAVATAR) $$img; \
	done
	cp -f site/apple-touch-icon-57x57-precomposed.png site/apple-touch-icon-precomposed.png
	cp -f site/apple-touch-icon-57x57-precomposed.png site/apple-touch-icon.png

.FAKE: all production jekyll sass watch serve dev publish gravatar
