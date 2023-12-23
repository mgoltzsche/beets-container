#!/bin/sh

set -eu

BEETS_LIBRARY=/data/beets

mkdir -p "$BEETSDIR" $BEETS_LIBRARY

for INITIALIZER in /entrypoint.d/*; do
	$INITIALIZER
done

if [ "$1" = sh ]; then
	exec "$@"
elif [ "$1" = web ]; then
	mkdir -p $BEETS_LIBRARY/web/mopidy $BEETS_LIBRARY/web/playlists
	IP="$(ip -4 a | grep inet | head -2 | tail -1 | sed -E 's!^ +inet ([^/]+)/.+$!\1!')" || (echo "ERROR: No IP found" >&2; false)
	echo "Running beets API (reverse-proxy) on http://${IP}:8337"
	nginx -e stderr & # start reverse-proxy
	exec beet "$@" # -p 8336 run beet API
else
	exec beet "$@"
fi
