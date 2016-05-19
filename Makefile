SHELL = /bin/bash
ICON = site/img/granola.jpg
JEKYLL_ARGS =
COMPASS_ARGS ?= --sass-dir site/css --css-dir public/css --images-dir img --javascripts-dir js --relative-assets
WATCH_EVENTS = create delete modify move
WATCH_DIRS = site

all: jekyll sass

# This uses separate invocations of $(MAKE) rather than dependencies for
# the production target, to avoid make -j running clean/all in parallel.
# COMPASS_ARGS is augmented and exported to override the ?= assignment when the
# submake runs.
production: export COMPASS_ARGS += -e production
production:
	$(MAKE) clean
	$(MAKE) all

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
#	jekyll serve --no-watch --skip-initial-build --host 0 --port 8000
	cd public && \
	browser-sync start -s --port 8000 --files ../site --reload-delay 2000 --no-notify --no-open --no-ui

dev:
	$(MAKE) -j2 watch serve

publish: production
	rsync -az --exclude=.git --delete-before public/. scampersand@n01se.net:scampersand.com/

icon:
	for x in 144 114 72 57; do \
	    geom=$${x}x$${x}; \
	    img=site/apple-touch-icon-$$geom-precomposed.png; \
	    rm -f $$img; \
	    gm convert -scale $$geom $(ICON) $$img; \
	done
	cp -f site/apple-touch-icon-57x57-precomposed.png site/apple-touch-icon-precomposed.png
	cp -f site/apple-touch-icon-57x57-precomposed.png site/apple-touch-icon.png

.ONESHELL: clean
clean:
	shopt -s dotglob extglob nullglob
	rm -rf public/!(.git|.|..)

.FAKE: all production jekyll sass watch serve dev publish icon clean
