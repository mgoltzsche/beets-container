#!/bin/sh

set -eu

BEETS_LIBRARY=/data/beets

mkdir -p "$BEETSDIR" $BEETS_LIBRARY

for INITIALIZER in /entrypoint.d/*; do
	$INITIALIZER
done

if [ "${1:-}" = sh ]; then
	exec "$@"
else
	exec beet "$@"
fi
