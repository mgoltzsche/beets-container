# Download/convert favicon
FROM alpine:3.19 AS favicon
RUN set -eux; \
	apk add --update --no-cache imagemagick; \
	wget -qO /logo.png https://raw.githubusercontent.com/beetbox/beets/e5d10004ae08bcbbaa4ee1397a4d889e8b3b52de/docs/_static/beets_logo_nobg.png; \
	convert /logo.png -define icon:auto-resize=256,128,64,32,16 /logo.ico


# Build actual beets container
#FROM ghcr.io/mgoltzsche/essentia:0.1.0
#RUN apk add --update --no-cache python3 py3-pip
#RUN rm /usr/lib/python3.11/EXTERNALLY-MANAGED

FROM python:3-alpine3.19
RUN apk add --update --no-cache nginx
#RUN apk add --update --no-cache cargo g++ openblas-dev ffmpeg flac py3-gst gst-plugins-good gst-plugins-bad chromaprint mpv bash jq recode nginx
# beets==1.6.0 + patches
RUN set -eux; \
	apk add --update --no-cache git; \
	pip install -e git+https://github.com/beetbox/beets.git@e5d10004ae08bcbbaa4ee1397a4d889e8b3b52de#egg=beets; \
	apk del --purge git
RUN python3 -m pip install \
	flask==2.1.2 \
	flask-cors==4.0.0 \
	Werkzeug==2.2.2

COPY --from=favicon /logo.ico /favicon.ico

RUN set -eux; \
	addgroup -g 1000 beets; \
	adduser -Su 1000 -G beets beets; \
	mkdir -m750 /data; \
	chown beets:beets /data; \
	mkdir /entrypoint.d; \
	printf '#!/bin/sh\n' > /entrypoint.d/00.sh; \
	chmod +x /entrypoint.d/00.sh
COPY config.web.yaml /etc/beets/config.yaml
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /
ENV BEETSDIR=/etc/beets
USER beets:beets
WORKDIR /data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["web"]
