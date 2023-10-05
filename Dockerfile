FROM python:3-alpine3.18
RUN apk add --update --no-cache cargo g++ openblas-dev ffmpeg
RUN python3 -m pip install \
	beets==1.6.0 \
	flask==3.0.0 \
	flask-cors==4.0.0 \
	pylast==5.2.0 \
	beets-describe==0.0.4 \
	beets-goingrunning==1.2.5
RUN apk add --update --no-cache beets
COPY beets.yaml /etc/beets.yaml
RUN set -eux; \
	addgroup -g 1000 beets; \
	adduser -Su 1000 -G beets beets; \
	mkdir -m750 /data; \
	chown beets:beets /data
USER beets:beets
WORKDIR /data
ENTRYPOINT ["beet", "-c", "/etc/beets.yaml"]
CMD ["web"]
