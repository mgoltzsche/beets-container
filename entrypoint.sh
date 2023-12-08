#!/bin/sh

set -eu

mkdir -p "$BEETSDIR"
[ -f "$BEETSDIR/config.yaml" ] || cp /etc/beets/default-config.yaml "$BEETSDIR/config.yaml"

if [ "$1" = sh ]; then
	exec "$@"
elif [ "$1" = web ]; then
	echo 'Running beets API (reverse-proxy) on http://127.0.0.1:8337'
	nginx -e stderr & # start reverse-proxy
	exec beet "$@" # -p 8336 run beet API
else
	exec beet "$@"
fi
