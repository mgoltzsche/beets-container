FROM python:3-alpine3.19
RUN apk add --update --no-cache libgcc
# beets==1.6.0 + patches
RUN set -eux; \
	BUILD_DEPS='git cargo'; \
	apk add --update --no-cache $BUILD_DEPS; \
	python3 -m pip install \
		flask==2.1.2 \
		flask-cors==4.0.0 \
		Werkzeug==2.2.2 \
		git+https://github.com/beetbox/beets.git@a780bfb189c59d390ea4e1ebd3e458b32ffac94b#egg=beets \
		beetstream==1.2.0 \
		beets-webm3u==0.4.3 \
		beets-webrouter==0.3.0; \
	apk del --purge $BUILD_DEPS

RUN set -eux; \
	addgroup -g 1000 beets; \
	adduser -Su 1000 -G beets beets; \
	mkdir -m750 /data; \
	chown beets:beets /data; \
	mkdir /entrypoint.d; \
	printf '#!/bin/sh\n' > /entrypoint.d/00.sh; \
	chmod +x /entrypoint.d/00.sh
COPY config.web.yaml /etc/beets/config.yaml
COPY entrypoint.sh /
ENV BEETSDIR=/etc/beets
USER beets:beets
WORKDIR /data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webrouter"]
