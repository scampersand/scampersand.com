C = card-bg.jpg
CW = 1694 1122 847 561
CO = $(foreach w, $(CW), $(basename $C)-$w.jpg)

.PHONY: all
all: $(CO)

.PHONY: clobber
clobber:
	rm -f $(CO)

#----------------------------------------------------------------------
# IMAGES
#----------------------------------------------------------------------

$(CO): $C

%.jpg %.png:
	w=$@; w=$${w%%.*}; w=$${w##*-}; \
	  convert -geometry $$w $^ $@
