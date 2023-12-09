#!/bin/sh

set -eu

mkdir -p "$BEETSDIR"
[ -f "$BEETSDIR/config.yaml" ] || cp /etc/beets/default-config.yaml "$BEETSDIR/config.yaml"

if [ "$1" = sh ]; then
	exec "$@"
elif [ "$1" = web ]; then
	IP="$(ip -4 a | grep inet | head -2 | tail -1 | sed -E 's!^ +inet ([^/]+)/.+$!\1!')" || (echo "ERROR: No IP found" >&2; false)
	echo "Running beets API (reverse-proxy) on http://${IP}:8337"
	nginx -e stderr & # start reverse-proxy
	exec beet "$@" # -p 8336 run beet API
else
	exec beet "$@"
fi
