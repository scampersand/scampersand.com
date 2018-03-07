SHELL = /bin/bash
JEKYLL_ARGS ?=
JEKYLL_DEST ?= public
JEKYLL_ENV ?= production
COMPASS_ARGS = -e $(JEKYLL_ENV) --sass-dir site/css --css-dir $(JEKYLL_DEST)/css --images-dir img --javascripts-dir js --relative-assets
WATCH_EVENTS = create delete modify move
WATCH_DIRS = site
GHP_REMOTE = git@github.com:scampersand/scampersand.github.io
NEXT_DEPLOY_DEST = scampersand@carlton.dreamhost.com:next.scampersand.com/
DREAM_DEPLOY_DEST = scampersand@carlton.dreamhost.com:scampersand.com/
VAGRANT_MAKE = vagrant ssh -- -t make -C /vagrant

export JEKYLL_ENV

default: help

######################################################################
ifeq ($(shell whoami), vagrant)

build:
	[[ $(JEKYLL_ENV) != production ]] || $(MAKE) clean
	$(MAKE) jekyll
	$(MAKE) sass
	[[ $(JEKYLL_ENV) != production ]] || ./post-process.bash

jekyll:
	jekyll build -d $(JEKYLL_DEST) $(JEKYLL_ARGS)

sass:
	compass compile $(COMPASS_ARGS)

watch:
	trap exit 2; \
	    while true; do \
		$(MAKE) build; \
		date > .sync; \
		inotifywait $(WATCH_EVENTS:%=-e %) --exclude '/\.' -r $(WATCH_DIRS); \
	    done

serve:
#	jekyll serve -d $(JEKYLL_DEST) --no-watch --skip-initial-build --host 0 --port 8000
	cd $(JEKYLL_DEST) && \
	    browser-sync start -s --port 8000 --files ../.sync --no-notify --no-open --no-ui

sync_serve:
	while [[ ! -e .sync ]]; do sleep 0.1; done
	$(MAKE) serve

draft: export JEKYLL_ARGS += --drafts
draft dev: export JEKYLL_ENV = development
draft dev: export JEKYLL_DEST = dev
draft dev:
	rm -f .sync
	$(MAKE) -j2 watch sync_serve

clean:
	if [[ -e $(JEKYLL_DEST)/.git ]]; then \
	    tmp=$$(mktemp -d clean.XXXXXX) && \
	    mv -T $(JEKYLL_DEST) $$tmp && \
	    mkdir $(JEKYLL_DEST) && \
	    mv $$tmp/.git $(JEKYLL_DEST) && \
	    rm -rf $$tmp; \
	else \
	    rm -rf $(JEKYLL_DEST); \
	fi

next deploy:
	@echo >&2
	@echo "#########################################" >&2
	@echo "# Please make $@ outside of vagrant" >&2
	@echo "#########################################" >&2
	@echo >&2
	@exit 1

######################################################################
else

build draft dev: up
	$(VAGRANT_MAKE) $@

up:
	vagrant status | grep -q '^default *running' || vagrant up

next: build
	$(MAKE) _deploy_next

deploy: build
	$(MAKE) _deploy_dream
	$(MAKE) _deploy_ghp

_deploy_next:
	echo 'Disallow: /' >> $(JEKYLL_DEST)/robots.txt
	rsync -az --exclude=.git --delete-before $(JEKYLL_DEST)/. $(NEXT_DEPLOY_DEST)

_deploy_dream:
	rsync -az --exclude=.git --delete-before $(JEKYLL_DEST)/. $(DREAM_DEPLOY_DEST)

_deploy_ghp:
	cd $(JEKYLL_DEST) && \
	    if [[ ! -d .git ]]; then \
		git init && \
		git remote add origin $(GHP_REMOTE); \
	    fi && \
	    git fetch --depth=1 origin master && \
	    git reset origin/master && \
	    git add -A && \
	    if git status --porcelain | grep -q .; then \
		git commit -m deploy; \
	    fi && \
	    git branch -u origin/master && \
	    git push

endif
######################################################################

help:
	@echo >&2
	@echo "#########################################" >&2
	@echo "# Target required (hint: dev or deploy)" >&2
	@echo "#########################################" >&2
	@echo >&2

.PHONY: _deploy_dream _deploy_ghp _deploy_next build clean default deploy \
    dev draft help jekyll next sass serve sync_serve up watch
