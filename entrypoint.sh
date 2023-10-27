#!/bin/sh

set -eu

mkdir -p "$BEETSDIR"
[ -f "$BEETSDIR/config.yaml" ] || cp /etc/beets/default-config.yaml "$BEETSDIR/config.yaml"

exec beet "$@"
