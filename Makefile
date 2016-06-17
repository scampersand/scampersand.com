SHELL = /bin/bash
JEKYLL_ARGS ?=
COMPASS_ARGS ?= --sass-dir site/css --css-dir public/css --images-dir img --javascripts-dir js --relative-assets
WATCH_EVENTS = create delete modify move
WATCH_DIRS = site

all:
	$(MAKE) jekyll
	$(MAKE) sass
	date > .sync

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
	    inotifywait $(WATCH_EVENTS:%=-e %) --exclude '/\.' -r $(WATCH_DIRS); \
	done

serve:
#	jekyll serve --no-watch --skip-initial-build --host 0 --port 8000
	cd public && \
	browser-sync start -s --port 8000 --files ../.sync --no-notify --no-open --no-ui

sync_serve:
	while [[ ! -e .sync ]]; do sleep 0.1; done
	$(MAKE) serve

draft: export JEKYLL_ARGS += --drafts
draft dev:
	rm -f .sync
	$(MAKE) -j2 watch sync_serve

publish: production
	rsync -az --exclude=.git --delete-before public/. scampersand@n01se.net:scampersand.com/

.ONESHELL: clean
clean:
	shopt -s dotglob extglob nullglob
	rm -rf public/!(.git|.|..)

.FAKE: all production jekyll sass watch serve sync_serve draft dev publish clean
