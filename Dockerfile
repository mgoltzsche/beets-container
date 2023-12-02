FROM python:3-alpine3.18
RUN apk add --update --no-cache cargo g++ openblas-dev ffmpeg flac py3-gst gst-plugins-good gst-plugins-bad chromaprint mpv bash jq recode
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
	beets-ytimport==1.4.1 \
	ytmusicapi==1.3.2 \
	yt-dlp==2023.11.16

RUN set -eux; \
	addgroup -g 1000 beets; \
	adduser -Su 1000 -G beets beets; \
	mkdir -m750 /data; \
	chown beets:beets /data
COPY config.yaml /etc/beets/default-config.yaml
COPY entrypoint.sh /
COPY play-playlist.sh /usr/local/bin/play-playlist
ENV BEETSDIR=/data/beets \
	EDITOR=vi
USER beets:beets
WORKDIR /data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["web"]
