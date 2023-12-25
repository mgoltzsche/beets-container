#!/bin/sh

mkdir -p /tmp/xtractor
[ -f "$BEETSDIR/config.yaml" ] || cp /etc/beets/default-config.yaml "$BEETSDIR/config.yaml"
[ -f "$BEETSDIR/genres.txt" ] || cp /etc/beets/default-genres.txt "$BEETSDIR/genres.txt"
