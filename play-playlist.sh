#!/bin/sh

set -eu

ARGS=
while [ $# -gt 1 ]; do
	ARGS="$ARGS $1"
	shift
done
PLAYLIST="$1"

exec mpv --no-video $ARGS --playlist="$PLAYLIST"
