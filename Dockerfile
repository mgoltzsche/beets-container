# Download/convert favicon
FROM alpine:3.18 AS favicon
RUN set -eux; \
	apk add --update --no-cache imagemagick; \
	wget -qO /logo.png https://raw.githubusercontent.com/beetbox/beets/e5d10004ae08bcbbaa4ee1397a4d889e8b3b52de/docs/_static/beets_logo_nobg.png; \
	convert /logo.png -define icon:auto-resize=256,128,64,32,16 /logo.ico


# Build actual beets container
FROM python:3-alpine3.18
RUN apk add --update --no-cache cargo g++ openblas-dev ffmpeg flac py3-gst gst-plugins-good gst-plugins-bad chromaprint mpv bash jq recode nginx
RUN python3 -m pip install \
	beets==1.6.0 \
	flask==2.1.2 \
	flask-cors==4.0.0 \
	Werkzeug==2.2.2 \
	pylast==5.2.0 \
	pyacoustid==1.3.0 \
	python3-discogs-client==2.7 \
	python-mpd2==3.1.0 \
	beets-describe==0.0.4 \
	beets-ytimport==1.5.0 \
	ytmusicapi==1.3.2 \
	yt-dlp==2023.11.16

# beets==1.6.0 + patches
RUN set -eux; \
	apk add --update --no-cache git; \
	pip install -e git+https://github.com/beetbox/beets.git@e5d10004ae08bcbbaa4ee1397a4d889e8b3b52de#egg=beets

COPY --from=favicon /logo.ico /favicon.ico

RUN set -eux; \
	addgroup -g 1000 beets; \
	adduser -Su 1000 -G beets beets; \
	mkdir -m750 /data; \
	chown beets:beets /data
COPY config.yaml /etc/beets/default-config.yaml
COPY entrypoint.sh /
COPY play-playlist.sh /usr/local/bin/play-playlist
COPY nginx.conf /etc/nginx/nginx.conf
ENV BEETSDIR=/data/beets \
	EDITOR=vi
USER beets:beets
WORKDIR /data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["web"]
