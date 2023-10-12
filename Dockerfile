FROM python:3-alpine3.18
RUN apk add --update --no-cache cargo g++ openblas-dev ffmpeg flac py3-gst gst-plugins-good gst-plugins-bad chromaprint jq recode
RUN python3 -m pip install \
	beets==1.6.0 \
	flask==3.0.0 \
	flask-cors==4.0.0 \
	pylast==5.2.0 \
	pyacoustid==1.3.0 \
	python-mpd2==3.1.0 \
	beets-describe==0.0.4 \
	beets-goingrunning==1.2.5
RUN set -eux; \
	addgroup -g 1000 beets; \
	adduser -Su 1000 -G beets beets; \
	mkdir -m750 /data; \
	chown beets:beets /data; \
	mkdir -p /home/beets/.config; \
	ln -s /data/beets-state /home/beets/.config/beets
COPY beets.yaml /etc/beets.yaml
COPY entrypoint.sh /entrypoint.sh
USER beets:beets
WORKDIR /data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["web"]
