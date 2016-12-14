C = card-bg.jpg
CW = 1694 1122 847 561
CO = $(foreach w, $(CW), $(basename $C)-$w.jpg)

V = scampersand-ripta-zoom.ogv
VW = 708
VO = $(foreach x, ogv webm high.mp4 main.mp4, $(basename $V)-$(VW).$x)

.PHONY: all
all: $(CO) $(VO)

.PHONY: clobber
clobber:
	rm -f $(CO) $(VO)

#----------------------------------------------------------------------
# IMAGES
#----------------------------------------------------------------------

$(CO): $C

%.jpg:
	w=$@; w=$${w%%.*}; w=$${w##*-}; \
	  convert -geometry $$w $^ $@

#----------------------------------------------------------------------
# VIDEOS
#----------------------------------------------------------------------

$(VO): $V

# https://trac.ffmpeg.org/wiki/TheoraVorbisEncodingGuide
%.ogv:
	w=$@; w=$${w%%.*}; w=$${w##*-}; \
	  ffmpeg -i $^ -vf scale=$$w:-1 -codec:v libtheora -qscale:v 5 -an -y $@

# https://trac.ffmpeg.org/wiki/Encode/VP9
# consider -lossless 1 instead of -crf 10 -b:v 0
%.webm:
	w=$@; w=$${w%%.*}; w=$${w##*-}; \
	  ffmpeg -i $^ -vf scale=$$w:-1 -c:v libvpx-vp9 -crf 10 -b:v 0 -an -y $@

%.high.mp4:
	w=$@; w=$${w%%.*}; w=$${w##*-}; \
	  ffmpeg -i $^ -vf scale=$$w:-2 -c:v libx264 -profile:v high -level 4.1 -movflags +faststart -an -y $@

%.main.mp4:
	w=$@; w=$${w%%.*}; w=$${w##*-}; \
	  ffmpeg -i $^ -vf scale=$$w:-2 -c:v libx264 -profile:v main -level 3.1 -movflags +faststart -an -y $@
